
64tass   --map "main.map" --output-exec=start --c256-pgz "../src/main.asm" --m65816  --list="app.lst" -Wno-portable -o "wiznet.pgz"
export FOENIXMGR='/mnt/d/Retro/Foenix/Repos/FoenixMgr'
sudo chmod 666 /dev/ttyUSB0
sudo chmod 666 /dev/ttyUSB1
sudo chmod 666 /dev/ttyUSB2
sudo chmod 666 /dev/ttyUSB3
python $FOENIXMGR/FoenixMgr/fnxmgr.py --copy wiznet.pgz