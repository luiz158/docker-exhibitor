#! /bin/bash -e
# Generates the default exhibitor config and launches exhibitor

MISSING_VAR_MESSAGE="must be set"
DEFAULT_AWS_REGION="us-west-2"
DEFAULT_DATA_DIR="/opt/zk/snapshots"
DEFAULT_LOG_DIR="/opt/zk/transactions"
DEFAULT_ZK_ENSEMBLE_SIZE=0
S3_SECURITY=""
: ${EXHIBITOR_HOSTNAME:?$MISSING_VAR_MESSAGE}
: ${AWS_REGION:=$DEFAULT_AWS_REGION}
: ${ZK_DATA_DIR:=$DEFAULT_DATA_DIR}
: ${ZK_LOG_DIR:=$DEFAULT_LOG_DIR}
: ${ZK_ENSEMBLE_SIZE:=$DEFAULT_ZK_ENSEMBLE_SIZE}

cat <<- EOF > /opt/exhibitor/defaults.conf
	zookeeper-data-directory=$ZK_DATA_DIR
	zookeeper-install-directory=/opt/zk
	zookeeper-log-directory=$ZK_LOG_DIR
	log-index-directory=$ZK_LOG_DIR
	cleanup-period-ms=300000
	check-ms=30000
	backup-period-ms=600000
	client-port=2181
	cleanup-max-files=20
	backup-max-store-ms=21600000
	connect-port=2888
	observer-threshold=0
	election-port=3888
	zoo-cfg-extra=tickTime\=2000&initLimit\=10&syncLimit\=5&quorumListenOnAllIPs\=true
	auto-manage-instances-settling-period-ms=0
	auto-manage-instances=1
	auto-manage-instances-fixed-ensemble-size=$ZK_ENSEMBLE_SIZE
EOF


if [[ -n ${AWS_ACCESS_KEY_ID} ]]; then
  cat <<- EOF > /opt/exhibitor/credentials.properties
    com.netflix.exhibitor.s3.access-key-id=${AWS_ACCESS_KEY_ID}
    com.netflix.exhibitor.s3.access-secret-key=${AWS_SECRET_ACCESS_KEY}
EOF
  S3_SECURITY="--s3credentials /opt/exhibitor/credentials.properties"
fi

if [[ -n ${S3_BUCKET} ]]; then
  echo "backup-extra=throttle\=&bucket-name\=${S3_BUCKET}&key-prefix\=${S3_PREFIX}&max-retries\=4&retry-sleep-ms\=30000" >> /opt/exhibitor/defaults.conf
  BACKUP_CONFIG="--configtype s3 --s3config ${S3_BUCKET}:${S3_PREFIX} ${S3_SECURITY} --s3region ${AWS_REGION} --s3backup true"
else
  BACKUP_CONFIG="--configtype file --fsconfigdir /opt/zk/local_configs --filesystembackup true"
fi

exec 2>&1

java -jar /opt/exhibitor/exhibitor.jar \
  --port 8181 --defaultconfig /opt/exhibitor/defaults.conf \
  ${BACKUP_CONFIG} \
  --hostname ${EXHIBITOR_HOSTNAME}
