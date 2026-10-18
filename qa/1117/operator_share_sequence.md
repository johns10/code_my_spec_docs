# Operator share/unshare sequence for story 1117 QA
Run by maintenance-0c as copy 7bd818cc at 2026-10-13T03:02:46Z, on certified commit b901d5706. QA observes; the QA role does not call share/unshare.

## 1. Before (shared)
- preview-7bd818cc-e623-4220-aa47-a95a443824a5.codemyspec.com: 200
- preview-c8eda3e8-ed17-49ec-86b0-1862b21f58b0.codemyspec.com: 200
- dev.codemyspec.com: 200
- astralbi.com: 200

## 2. unshare_copy_app
```
Returned:
No longer shared.
```
- preview-7bd818cc-e623-4220-aa47-a95a443824a5.codemyspec.com: 404
- preview-c8eda3e8-ed17-49ec-86b0-1862b21f58b0.codemyspec.com: 200
- dev.codemyspec.com: 200
- astralbi.com: 200

## 3. share_copy_app
```
Returned:
Shared at https://preview-7bd818cc-e623-4220-aa47-a95a443824a5.codemyspec.com.
```
- preview-7bd818cc-e623-4220-aa47-a95a443824a5.codemyspec.com: 200
- preview-c8eda3e8-ed17-49ec-86b0-1862b21f58b0.codemyspec.com: 200
- dev.codemyspec.com: 200
- astralbi.com: 200
