#!/bin/bash
cd ../..
if [ ! -d "user-service" ]; then
    git clone https://github.com/SVBazuev/user-service.git
fi
if [ ! -d "notification-service" ]; then
    git clone https://github.com/SVBazuev/notification-service.git
fi
