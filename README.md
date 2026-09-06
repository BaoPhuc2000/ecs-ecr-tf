# Bài 3 — Terraform hoá ECR + ECS (thay cho phần tạo tay ở Bài 2)

Khác với Bài 2 (tạo tay qua Console), lần này **Terraform tạo toàn bộ hạ tầng**:
ECR repo, ECS Cluster, Task Definition, Service, Security Group — không cần vào Console click tay nữa.

Điểm mấu chốt cần hiểu trong `infra/ecs.tf`:
- Task Definition dùng tạm image `nginx` public lúc `terraform apply` lần đầu (vì ECR
  đang trống, chưa có image thật) — sau đó GitHub Actions tự thay bằng image thật.
- `lifecycle { ignore_changes = [...] }` trên Task Definition và Service — để Terraform
  KHÔNG đè ngược lại image cũ mỗi lần `apply` sau khi CI/CD đã deploy image mới.

## 1. Bootstrap remote state (làm 1 lần)

```bash
aws s3api create-bucket --bucket <your-tfstate-bucket-name> --region us-east-1
aws s3api put-bucket-versioning --bucket <your-tfstate-bucket-name> --versioning-configuration Status=Enabled

aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST
```

Mở `infra/versions.tf`, bỏ comment block `backend "s3"`, điền tên bucket thật.

## 2. IAM Role cho GitHub Actions (dùng lại OIDC Provider đã tạo ở Bài 2 nếu còn)

Trust policy — nhớ bài học từ Bài 2: `sub` phải khớp CHÍNH XÁC định dạng GitHub thật sự
gửi lên (có thể kèm `@<id>` sau username/repo — kiểm tra qua CloudTrail nếu bị AccessDenied):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::<ACCOUNT_ID>:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": { "token.actions.githubusercontent.com:aud": "sts.amazonaws.com" },
        "StringLike": { "token.actions.githubusercontent.com:sub": "repo:<GITHUB_USER>/<REPO>:*" }
      }
    }
  ]
}
```

Quyền cần cho role này (rộng hơn Bài 2 một chút vì giờ role vừa chạy Terraform vừa deploy):
- Terraform cần quyền tạo/sửa/xoá: ECR, ECS, IAM Role, CloudWatch Logs, EC2 Security Group,
  và đọc/ghi S3 state bucket + DynamoDB lock table.
- Cách đơn giản nhất cho lab: gắn tạm `PowerUserAccess` (không dùng cho production).

## 3. Biến GitHub repo (Settings → Secrets and variables → Actions → Variables)

| Name | Giá trị |
|---|---|
| `AWS_ROLE_ARN` | ARN role vừa tạo |
| `AWS_REGION` | `us-east-1` |

## 4. Thứ tự chạy

1. Push code → workflow `Terraform Infra` tự chạy `terraform apply` (vì push thẳng vào `main`,
   không qua PR trong lần đầu này) → tạo ECR/ECS/SG.
2. Sau khi hạ tầng đã tồn tại, sửa gì đó trong `app/` (ví dụ đổi message) → push → workflow
   `Deploy App` tự build/push/deploy image thật.
3. Lấy Public IP: `aws ecs list-tasks --cluster ecs-lab-demo-cluster` rồi
   `aws ecs describe-tasks --cluster ecs-lab-demo-cluster --tasks <task-arn>` để xem Public IP,
   test `http://<ip>:8080`.

## 5. Dọn dẹp

```bash
cd infra
terraform destroy
```
