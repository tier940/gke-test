# gke-test

## SAの準備

Terrafromでapplyするため以下を叩く。

```bash
# 環境変数保存
export GCP_PROJECT_ID=プロジェクトID
echo $GCP_PROJECT_ID

# tfstate保存用のGCSアカウント
gcloud iam service-accounts create terraform-gcs
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:terraform-gcs@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.admin

#　terrafrom操作用のアカウント
gcloud iam service-accounts create terraform-deploy
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:terraform-deploy@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/editor \
  --role=roles/resourcemanager.projectIamAdmin \
  --role=roles/compute.networkAdmin

#　作成確認
gcloud iam service-accounts list | grep terraform-gcs
gcloud iam service-accounts list | grep terraform-deploy
```

## サービスアカウントの取得

Terrafromで実行するためjsonを叩きだす。

```bash
cd ./credentials

# tfstate保存用のGCSアカウント
gcloud iam service-accounts keys create terraform-gcs.json \
  --iam-account=terraform-gcs@$GCP_PROJECT_ID.iam.gserviceaccount.com

#　terrafrom操作用のアカウント
gcloud iam service-accounts keys create terraform-deploy.json \
  --iam-account=terraform-deploy@$GCP_PROJECT_ID.iam.gserviceaccount.com
```

### メモ
