BUILD=/tmp/syncbuild

build:
	rm -rf ${BUILD}
	realsd publish --html  --to html/sd/buglist
	perl ./microserver &
	sleep 3
	mkdir ${BUILD}
	cd ${BUILD} && wget -m -np http://localhost:8080 
	cp html/bg.jpg ${BUILD}/localhost:8080/bg.jpg
	perl dump_sd_help.pl > ${BUILD}/localhost:8080/sd/using
	cd ${BUILD}/localhost:8080 && rsync -avz * root@mrt.bestpractical.com:/var/www/docs/syncwith.us/ 
	wget http://localhost:8080/_elements/exit
