BUILD=/tmp/syncbuild

build:
	rm -rf ${BUILD}
	realsd ticket list --html > html/sd/sd-bug-output.html
	perl ./microserver &
	sleep 3
	mkdir ${BUILD}
	cd ${BUILD} && wget -m -np http://localhost:8080 
	cp html/bg.jpg ${BUILD}/localhost:8080/bg.jpg
	cd ${BUILD}/localhost:8080 && rsync -avz * root@mrt.bestpractical.com:/var/www/docs/syncwith.us/ 
	wget http://localhost:8080/_elements/exit