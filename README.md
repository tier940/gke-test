# gke-test
## SAの準備
GKE作成後に下記を叩く。

```bash
gcloud iam service-accounts create gke-test
gcloud iam service-accounts list
gcloud projects add-iam-policy-binding $PROJECT_ID --member=serviceAccount:$SA_NAME --role=roles/storage.admin
```

### SAのロール変更
なぜか`roles/container.admin`が付けられないので手動で`Kubernetes Engine 管理者`をつける。
![IAM](https://console.cloud.google.com/iam-admin/iam)

## SAの登録
GithubのSettingsにある`Repository secrets`にてSAのCredentiaを貼り付け。

```base
cd ./credentials
gcloud iam service-accounts keys create key.json --iam-account=$SA_NAME
```

### Memo
![GKE デフォルトのコンテナ リソース リクエスト](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview#default_container_resource_requests)
