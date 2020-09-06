IPADDRESS = ${NODE_IP}

new: delete create
delete:
	kubectl delete -f deployment.yaml
create:
	kubectl create -f deployment.yaml

nodeport:
	kubectl get svc test-sftp -o jsonpath='{.spec.ports[0].nodePort}'

connect:
	docker run --rm -it \
	-e IPADDRESS=${IPADDRESS} \
	openssh \
 	/bin/sh -c 'test | sshpass -p 'test' sftp -oStrictHostKeyChecking=no -P $(shell kubectl get svc test-sftp -o jsonpath='{.spec.ports[0].nodePort}') test@$$IPADDRESS'

.PHONY:test
test: run
	sleep 1;\
	docker run --name=sftp-test1 --rm --net=host \
	openssh \
	/bin/sh -c 'test | sshpass -p 'test' sftp -P 8080 -oStrictHostKeyChecking=no test@localhost' || true ; \
	docker rm -f sftp-test sftp-test1 || true


run:
	docker build --tag=test .; \
	docker run --name=sftp-test --rm -p 8080:8080 -d test test:test

rm:
	docker rm -f sftp-test sftp-test1 || true
