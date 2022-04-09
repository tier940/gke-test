# gke-test

## SAの準備

Terrafromでapplyするため以下を叩く。

```bash
# Google Cloud SDK ログイン
gcloud auth login 
gcloud auth application-default login

# 環境変数保存
export GCP_PROJECT_ID=プロジェクトID
echo ${GCP_PROJECT_ID}

# 
gcloud config set project ${GCP_PROJECT_ID}

# tfstate保存用のGCSアカウント
gcloud iam service-accounts create terraform-gcs

## ストレージ管理者
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
    --member=serviceAccount:terraform-gcs@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/storage.admin

#　terrafrom操作用のアカウント(一気に作れないため三回たたく)
gcloud iam service-accounts create terraform-deploy

## 編集者
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
    --member=serviceAccount:terraform-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/editor

## Project IAM 管理者
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
    --member=serviceAccount:terraform-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/resourcemanager.projectIamAdmin

## Compute ネットワーク管理者
gcloud projects add-iam-policy-binding ${GCP_PROJECT_ID} \
    --member=serviceAccount:terraform-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
    --role=roles/compute.networkAdmin

```

## サービスアカウントの取得

Terrafromで実行するためjsonを叩きだす。

```bash
cd ./credentials

# tfstate保存用のGCSアカウント
gcloud iam service-accounts keys create terraform-gcs.json \
    --iam-account=terraform-gcs@${GCP_PROJECT_ID}.iam.gserviceaccount.com

#　terrafrom操作用のアカウント
gcloud iam service-accounts keys create terraform-deploy.json \
    --iam-account=terraform-deploy@${GCP_PROJECT_ID}.iam.gserviceaccount.com

```

### メモ

<details>

```bash
# GitHub Actions OIDC Token for GCP.

## 環境変数保存
export GCP_PROJECT_ID=プロジェクトID
export POOL_NAME=github-actions
export PROVIDER_NAME=gha-provider
export GITHUB_REPO=tier940/gke-test

## IAM Service Account Credentials API を有効
gcloud services enable iamcredentials.googleapis.com

## Workload IdentityにPoolを作成
gcloud iam workload-identity-pools create ${POOL_NAME} \
    --location="global" --display-name="use from GitHub Actions"
export WORKLOAD_IDENTITY_POOL_ID=$( \
    gcloud iam workload-identity-pools describe ${POOL_NAME} \
    --location="global" --format="value(name)" \
)

## PoolにProvierを作成
gcloud iam workload-identity-pools providers create-oidc ${PROVIDER_NAME} \
    --location="global" \
    --workload-identity-pool=${POOL_NAME} \
    --display-name="use from GitHub Actions provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository,attribute.actor=assertion.  actor,attribute.aud=assertion.aud" \
    --issuer-uri="https://token.actions.githubusercontent.com"

## 可能なリポジトリを絞る
gcloud iam service-accounts create gha-provider
gcloud iam service-accounts add-iam-policy-binding gha-provider@${GCP_PROJECT_ID}.iam.gserviceaccount.com \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/${WORKLOAD_IDENTITY_POOL_ID}/attribute.repository/${GITHUB_REPO}"

## シークレット情報
echo gha-provider@${GCP_PROJECT_ID}.iam.gserviceaccount.com
echo ${WORKLOAD_IDENTITY_POOL_ID}/providers/${PROVIDER_NAME}

```

</details>
