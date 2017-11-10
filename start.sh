screen -d -S testrpc -m testrpc  -m "innocent garden charge slice ver immune swap portion result gospel uniform veteran"

#screen -d -S node -m sh
cd backend
truffle migrate
screen -d -S node -m npm run start
cd ..
echo "all screens started."

http-server frontend

screen -X -S testrpc kill
screen -X -S node kill

echo "All screens terminated."
