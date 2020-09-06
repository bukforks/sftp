IPADDRESS = ${NODE_IP}

delete:
	k delete -f deployment.yaml

deploy:
	k create -f deployment.yaml; \

new: delete deploy

connect:
	docker run --rm -it \
	-e IPADDRESS=${IPADDRESS} \
	openssh \
 	/bin/sh -c 'test | sshpass -p 'test' sftp -oStrictHostKeyChecking=no -P $(shell kubectl get svc demo-nodeport -o jsonpath='{.spec.ports[0].nodePort}') test@$$IPADDRESS'

run:
	docker build --tag=test .; \
	docker run --name=sftp-test --rm -p 22:22 -d test test:test

rm:
	docker rm -f sftp-test sftp-test1 || true

.PHONY:test
test: run
	sleep 1;\
	docker run --name=sftp-test1 --rm --net=host \
	openssh \
	/bin/sh -c 'test | sshpass -p 'test' sftp -oStrictHostKeyChecking=no test@localhost' || true ; \
	docker rm -f sftp-test sftp-test1 || true