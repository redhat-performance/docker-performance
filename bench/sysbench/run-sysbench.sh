#!/bin/sh

################################################################################
#
#  run-sysbench.sh
#
#             - sysbench automation script
#
#  Usage:     Adjust variables below before running
#
#  MAINTAINER:  jeder@redhat.com
#
#
################################################################################

################################################################################
#  Define Global Variables and Functions
################################################################################

if [ $# -lt 2 ]; then
        echo "syntax $0 test_type test_name"
        echo " i.e. $0 cpu|oltp docker.test1"
        exit 1;
fi

function timestamp {
        echo "$(date +%Y-%m-%d_%H_%M_%S)"
}

TESTTYPE=$1
TESTNAME=$2
DB_DIR=/root
DB_DATA_DIR=$DB_DIR/data
DB_LOG_DIR=$DB_DIR/log
CPU_SAMPLES=10
CPU_PRIME=4000
OLTP_ROWS=2000000
OLTP_SECONDS=300
OUTDIR=/results

if [ $container == docker ]; then
	echo "Running in a container"
fi

if [ ! -d $OUTDIR ]; then
	echo "$OUTDIR does not exist.  Exiting."
	exit 1
fi

if [[ ! -d $DB_DATA_DIR  && ! -d $DB_LOG_DIR ]]; then
	echo "Database storage directories do not exist; creating $DB_DATA_DIR and $DB_LOG_DIR"
	mkdir -p $DB_DATA_DIR $DB_LOG_DIR
fi

if [ ! $(which sysbench) ]; then echo "sysbench not installed...installing" ; yum install -y -q /root/docker-performance/bench/sysbench/rhel7/*rpm ; fi

function run_cpu_test {
OUTFILE=$OUTDIR/`timestamp`.sysbench.$TESTNAME.cpu.cpu.max.prime.$CPU_PRIME.samples.$CPU_SAMPLES.log
for i in `seq $CPU_SAMPLES` ; do sysbench --test=cpu --cpu-max-prime=$CPU_PRIME run >> $OUTFILE ; done
grep "total time:" $OUTFILE | awk '{print $3}' | sed -e 's/s//g' | /root/docker-performance/utils/histogram.py | tee -a > $OUTFILE.histogram
}

function setup_oltp_test {
DB=mariadb
ENGINE=innodb

if [ ! $(which mysqld_safe) ]; then echo "mariadb not installed...installing" ; yum install -y -q mariadb-server mariadb ; fi

echo "starting database"
pkill mysqld_safe
mysqld_safe --user=root --basedir=/usr --skip-grant-tables --innodb_data_home_dir=$DB_DATA_DIR \
            --innodb_buffer_pool_size=2048M --innodb_log_group_home_dir=$DB_LOG_DIR --innodb_log_buffer_size=64M \
            --innodb_additional_mem_pool_size=32M --innodb_flush_log_at_trx_commit=0 --innodb_log_file_size=1G \
            --innodb_thread_concurrency=1000 --max_connections=1000 --table_cache=4096 --innodb_flush_method=O_DIRECT &
# gotta wait for db to initialize itself before continuing
sleep 30
}

function setup_oltp_database {
echo "setting up sysbench database"
mysqladmin -uroot -f drop sbtest
mysqladmin -uroot create sbtest
}

function run_oltp_test {
OUTFILE=$OUTDIR/`timestamp`.sysbench.$container.$TESTNAME.oltp.$DB.rows.$OLTP_ROWS.seconds.$OLTP_SECONDS.$ENGINE.log

for NUM_THREADS in 1 2 4 8 16 32;
	do
	setup_oltp_database
	sysbench --test=oltp --db-driver=mysql --oltp-table-size=$OLTP_ROWS --max-requests=0 --mysql-table-engine=InnoDB \
                 --mysql-user=root --mysql-engine-trx=yes --num-threads=1 prepare
	echo 3 > /proc/sys/vm/drop_caches ; sync
	sleep 5
	sysbench --test=oltp --db-driver=mysql --oltp-table-size=$OLTP_ROWS --max-time=$OLTP_SECONDS --max-requests=0 \
                 --mysql-table-engine=InnoDB --mysql-user=root --mysql-engine-trx=yes --num-threads=$NUM_THREADS run >> $OUTFILE
done
}

if [ "$TESTTYPE" = cpu ]; then
	echo "`timestamp` running sysbench $TESTTYPE test for $CPU_SAMPLES samples"
	run_cpu_test
fi

if [ "$TESTTYPE" = oltp ]; then
	echo "`timestamp` running sysbench $TESTTYPE test with $OLTP_ROWS rows for $OLTP_SECONDS seconds"
	setup_oltp_test
	setup_oltp_database
	run_oltp_test
fi
