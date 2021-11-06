# gke-test

```bash
gcloud iam service-accounts create gke-test
gcloud iam service-accounts list
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SA_NAME --role=roles/container.admin --role=roles/storage.admin
gcloud iam service-accounts keys create key.json --iam-account=$SA_NAME
cat key.json | base64
```
