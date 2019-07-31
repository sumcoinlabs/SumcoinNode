[Unit] 
Description=Sumcoin Daemon
After=network.target 

[Service] 
User=sumcoind 
Group=sumcoind 

Type=forking 
PIDFile=/home/sumcoind/.sumcoin/sumcoind.pid
ExecStart=/home/sumcoind/bin/sumcoind -pid=/home/sumcoind/.sumcoin/sumcoind.pid -conf=/home/sumcoind/.sumcoin/sumcoin.conf -datadir=/home/sumcoind/.sumcoin -daemon -disablewallet

Restart=always 
PrivateTmp=true 
TimeoutStopSec=60s 
TimeoutStartSec=2s 
StartLimitInterval=120s 
StartLimitBurst=5 

[Install] 
WantedBy=multi-user.target 
