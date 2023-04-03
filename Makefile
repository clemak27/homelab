SOPS = SOPS_AGE_KEY_FILE=./key.txt sops

# files

key.txt:
	sops --decrypt modules/init/age_key.enc > key.txt

clean:
	rm -rf bin
	rm -f key.txt

# k3s

k3s/init_argocd: key.txt
	helm repo add argo-cd https://argoproj.github.io/argo-helm && \
	helm dep update cluster/argocd/application
	kubectl create namespace argocd && \
	kubectl -n argocd create secret generic helm-secrets-private-keys --from-file=key.txt && \
	helm install -n argocd argocd cluster/argocd/application && \
	sleep 75 && \
	kubectl delete -n argocd secrets argocd-initial-admin-secret

k3s/create_argocd_applications:
	find ./cluster -name 'applications.yaml' -exec kubectl -n argocd apply -f {} \;

k3s/create_cert_issuer: key.txt
	$(SOPS) --decrypt cluster/cert-manager/issuer/issuer.yaml > cluster/cert-manager/issuer/issuer_unenc.yaml && \
	kubectl apply -n cert-manager -f cluster/cert-manager/issuer/issuer_unenc.yaml && \
	rm -f cluster/cert-manager/issuer/issuer_unenc.yaml
