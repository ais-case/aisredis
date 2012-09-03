#!/bin/bash

# Some setup
MY_RUBY_VERSION="1.8.7-p370"
cd `dirname $0`
BASEPATH=`pwd`
LOG="$BASEPATH/log/setup.log"
if [ -f "${LOG}" ]; then
    rm ${LOG}
fi

echo
echo "If something goes wrong, check the logfile at ${LOG} for more detailed info"
echo

# RVM, Ruby and gemset setup

echo -n "Installing rvm... "
curl -L get.rvm.io 2>/dev/null | bash -s stable 1>>${LOG} 2>&1
source ~/.rvm/scripts/rvm 
echo "done."

echo -n "Installing openssl, this may take a while... "
rvm pkg install openssl 1>>${LOG} 2>&1
rm -rf ~/.rvm/src/openssl* 1>>${LOG} 2>&1
echo "done."

echo -n "Installing libyaml, this may take a while... "
rvm pkg install libyaml 1>>${LOG} 2>&1
rm -rf ~/.rvm/src/yaml* 2>&1
echo "done."

echo -n "Installing ruby ${MY_RUBY_VERSION}, this may take a while... "
rvm install ${MY_RUBY_VERSION} 1>>${LOG} 2>&1
rm -rf ~/.rvm/src/ruby-${MY_RUBY_VERSION} 2>&1
rvm use ${MY_RUBY_VERSION} 1>>${LOG} 2>&1
echo "done."

echo -n "Setting up gemset for project... "
rvm gemset create aisredis 1>>${LOG} 2>&1
rvm use "1.8.7@aisredis" 1>>${LOG} 2>&1
echo "done."

echo -n "Installing project dependencies... "
gem install bundler 1>>${LOG} 2>&1
bundle install 1>>${LOG} 2>&1
echo "done."

# redis compilation

# Create compile environment and switch to it
mkdir -p ${BASEPATH}/vendor/redis
cd ${BASEPATH}/vendor/redis
BUILDPATH=`pwd`

echo -n "Downloading redis into ${BUILDPATH}... "
curl -o redis.tgz http://redis.googlecode.com/files/redis-2.4.16.tar.gz 1>>${LOG} 2>&1
tar xvzf redis.tgz 1>>${LOG} 2>&1
rm redis.tgz
echo "done."

echo -n "Compiling redis... "
cd redis-2.4.16
make 1>>${LOG} 2>&1
cp src/redis-server src/redis-cli ${BASEPATH}
cd ${BUILDPATH}
rm -r redis-2.4.16
echo "done."

# ZeroMQ library compilation

# Create compile environent for zmq and switch to it
mkdir -p ${BASEPATH}/vendor/zeromq
cd ${BASEPATH}/vendor/zeromq
BUILDPATH=`pwd`

echo -n "Downloading zeromq into ${BUILDPATH}... "
curl -o zmq.tgz http://download.zeromq.org/zeromq-2.2.0.tar.gz  1>>${LOG} 2>&1
tar xvzf zmq.tgz 1>>${LOG} 2>&1
rm zmq.tgz
echo "done."

echo -n "Compiling zeromq... "
cd zeromq-2.2.0
./configure --prefix=$BUILDPATH/zmq 1>>${LOG} 2>&1 && make install 1>>${LOG} 2>&1
cd ${BUILDPATH}
rm -r zeromq-2.2.0
echo "done."

ZMQ_GEM_PATH="${HOME}/.rvm/gems/ruby-${MY_RUBY_VERSION}@aisredis/gems/ffi-rzmq-0.9.3"
echo -n "Symlinking zmq libraries from ${ZMQ_GEM_PATH}... "
for LIBFILE in ${BUILDPATH}/zmq/lib/*;
do
    DEST="${ZMQ_GEM_PATH}/ext/`basename ${LIBFILE}`"
    if [ -e "${DEST}" ]; then
        rm ${DEST} 1>>${LOG} 2>&1
    fi
    
    ln -s ${LIBFILE} ${DEST} 1>>${LOG} 2>&1
done;
echo "done."

# Now install rvmrc
cd ${BASEPATH} && cd ..
cp ${BASEPATH}/.rvmrc.distrib ${BASEPATH}/.rvmrc
echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"' >> ~/.bashrc

echo
echo "Done with installation"
echo
echo "Now run:"
echo "source ~/.rvm/scripts/rvm && cd aisredis"
