---
tags: [bash-course, real-world, level-05]
---

# DevOps

DevOps engineers wrap Bash around every stage of shipping software: building artifacts, running tests, pushing images, and gluing together tools like Docker, Terraform, and Kubernetes with shell scripts.

## Example
```bash
docker build -t app:$(git rev-parse --short HEAD) .
```

## Notes

## Related
- [[05 Real World]]
