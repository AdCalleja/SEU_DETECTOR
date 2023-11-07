DOCKER_CONTAINER_NAME_OR_ID := mitysom_docker

all: devicetree c_docker_build

devicetree:
	wsl cp /mnt/c/Users/adrian/Desktop/code/seu_detector_ref_design/dev_5csx_h6_42a/SEU_DETECTOR/sw/src/uio_seu_detector.dtso ~/devicetree_build
	wsl dtc -I dts -O dtb -o ~/devicetree_build/uio_seu_detector.dtbo ~/devicetree_build/uio_seu_detector.dtso
	wsl cp ~/devicetree_build/uio_seu_detector.dtbo /mnt/c/Users/adrian/Desktop/code/seu_detector_ref_design/dev_5csx_h6_42a/SEU_DETECTOR/sw/output

c_docker_build:
	docker cp ./src/ mitysom_docker:/home/user/share/seu_detector
	docker exec -it $(DOCKER_CONTAINER_NAME_OR_ID) /bin/bash -c "source /home/user/poky_sdk/environment-setup-cortexa8hf-neon-poky-linux-gnueabi; $${CC} -o /home/user/share/seu_detector/seu_detector.bin /home/user/share/seu_detector/*.c /home/user/share/seu_detector/*.h
	docker cp mitysom_docker:/home/user/share/seu_detector/seu_detector.bin ./output

headers_build:
	wsl cp /mnt/c/Users/adrian/Desktop/code/seu_detector_ref_design/dev_5csx_h6_42a/dev_5csx_h6_42a.sopcinfo ~/headers_build
	wsl cd ~/headers_build; ./my_sopc-create-header-files
	wsl cp ~/headers_build/*.h /mnt/c/Users/adrian/Desktop/code/seu_detector_ref_design/dev_5csx_h6_42a/SEU_DETECTOR/sw/output/headers
