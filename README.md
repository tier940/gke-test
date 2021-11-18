# gke-test

## SAの準備

Terrafromでapplyするため以下を叩く。

```bash
gcloud iam service-accounts create terraform-gcs
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SA_NAME --role=roles/storage.admin

gcloud iam service-accounts create terraform-deploy
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SA_NAME --role=roles/editor --role=roles/resourcemanager.projectIamAdmin --role=roles/compute.networkAdmin

gcloud iam service-accounts list | grep terraform-gcs
gcloud iam service-accounts list | grep terraform-deploy
```

## SAの登録

GithubのSettingsにある`Repository secrets`にてterraform-gcsのサービスアカウントjsonとterraform-deployを貼り付け。

```base
cd ./credentials
gcloud iam service-accounts keys create terraform-gcs.json --iam-account=$SA_NAME
gcloud iam service-accounts keys create terraform-deploy.json --iam-account=$SA_NAME
```

### メモ
