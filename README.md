# gke-test

## SAの準備

Terrafromでapplyするため以下を叩く。

```bash
# 環境変数保存
export GCP_PROJECT_ID=プロジェクトID
echo $GCP_PROJECT_ID


# tfstate保存用のGCSアカウント
gcloud iam service-accounts create terraform-gcs

## ストレージ管理者
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:terraform-gcs@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/storage.admin


#　terrafrom操作用のアカウント(一気に作れないため三回たたく)
gcloud iam service-accounts create terraform-deploy

## 編集者
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:terraform-deploy@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/editor

## Project IAM 管理者
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:terraform-deploy@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/resourcemanager.projectIamAdmin

## Compute ネットワーク管理者
gcloud projects add-iam-policy-binding $GCP_PROJECT_ID \
  --member=serviceAccount:terraform-deploy@$GCP_PROJECT_ID.iam.gserviceaccount.com \
  --role=roles/compute.networkAdmin
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
