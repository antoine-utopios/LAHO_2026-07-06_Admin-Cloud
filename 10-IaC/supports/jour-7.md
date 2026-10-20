---
marp: true
title: Admin Cloud — CL-IAC — Jour 7
theme: utopios
paginate: true
author: Ihab ABADI
header: "![h:70px](https://utopios-marp-assets.s3.eu-west-3.amazonaws.com/logo_blanc.svg)"
footer: "Utopios® Tous droits réservés"
client: Utopios
---

<!-- _class: lead -->

# La chaîne complète Terraform + Ansible

<img style="width:190px" src="data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNTAgNjAuMTUiPgogIDxwYXRoIGNsYXNzPSJ0ZXh0IiBmaWxsPSIjMDAwIiBkPSJNNzcuMzUgNy44NlY0LjYzaC0zdjMuMjNoLTEuNDZWLjExaDEuNTF2My4yNWgzVi4xMWgxLjUxdjcuNzV6bTcgMGgtMS4ybC0uMTEtLjM4YTMuMjggMy4yOCAwIDAgMS0xLjcuNTJjLTEuMDYgMC0xLjUyLS43LTEuNTItMS42NiAwLTEuMTQuNTEtMS41NyAxLjctMS41N2gxLjR2LS42MmMwLS42Mi0uMTgtLjg0LTEuMTEtLjg0YTguNDYgOC40NiAwIDAgMC0xLjYxLjE3TDgwIDIuNDJhNy44OSA3Ljg5IDAgMCAxIDItLjI2YzEuODMgMCAyLjM3LjYyIDIuMzcgMnptLTEuNDMtMi4xMWgtMS4wOGMtLjQ4IDAtLjYxLjEzLS42MS41NXMuMTMuNTYuNTkuNTZhMi4zNyAyLjM3IDAgMCAwIDEuMS0uMjl6TTg3LjQzIDhhNy4xMiA3LjEyIDAgMCAxLTItLjMybC4yLTEuMDdhNi43NyA2Ljc3IDAgMCAwIDEuNzMuMjRjLjY1IDAgLjc0LS4xNC43NC0uNTZzLS4wNy0uNTItMS0uNzNjLTEuNDItLjMzLTEuNTktLjY4LTEuNTktMS43NnMuNDktMS42NSAyLjE2LTEuNjVhOCA4IDAgMCAxIDEuNzUuMmwtLjE0IDEuMTFhMTAuNjYgMTAuNjYgMCAwIDAtMS42LS4xNmMtLjYzIDAtLjc0LjE0LS43NC40OHMwIC40OC44Mi42OGMxLjYzLjQxIDEuNzguNjIgMS43OCAxLjc3Uzg5LjE5IDggODcuNDMgOHptNi42OC0uMTFWNGMwLS4zLS4xMy0uNDUtLjQ3LS40NWE0LjE0IDQuMTQgMCAwIDAtMS41Mi40NXYzLjg2aC0xLjQ2VjBsMS40Ni4yMnYyLjQ3YTUuMzEgNS4zMSAwIDAgMSAyLjEzLS41NGMxIDAgMS4zMi42NSAxLjMyIDEuNjV2NC4wNnptMi42OC02LjM4Vi4xMWgxLjQ2djEuMzd6bTAgNi4zOFYyLjI3aDEuNDZ2NS41OXptMi42Mi01LjU0YzAtMS40Ljg1LTIuMjIgMi44My0yLjIyYTkuMzcgOS4zNyAwIDAgMSAyLjE2LjI1bC0uMTcgMS4yNWExMi4yMSAxMi4yMSAwIDAgMC0xLjk1LS4yYy0xIDAtMS4zNy4zNC0xLjM3IDEuMTZWNS41YzAgLjgxLjMzIDEuMTYgMS4zNyAxLjE2YTEyLjIxIDEyLjIxIDAgMCAwIDEuOTUtLjJsLjE3IDEuMjVhOS4zNyA5LjM3IDAgMCAxLTIuMTYuMjVjLTIgMC0yLjgzLS44MS0yLjgzLTIuMjJ6TTEwNy42MyA4Yy0yIDAtMi41My0xLjA2LTIuNTMtMi4yVjQuMzZjMC0xLjE1LjU0LTIuMiAyLjUzLTIuMnMyLjUzIDEuMDYgMi41MyAyLjJ2MS40MWMuMDEgMS4xNS0uNTMgMi4yMy0yLjUzIDIuMjN6bTAtNC42M2MtLjc4IDAtMS4wOC4zMy0xLjA4IDF2MS41YzAgLjYzLjMgMSAxLjA4IDFzMS4wOC0uMzMgMS4wOC0xVjQuMzFjMC0uNjMtLjMtLjk2LTEuMDgtLjk2em02LjY0LjA5YTExLjU3IDExLjU3IDAgMCAwLTEuNTQuODF2My42aC0xLjQ2di01LjZoMS4yM2wuMS42MmE2LjYzIDYuNjMgMCAwIDEgMS41My0uNzN6TTEyMC4xIDZhMS43MyAxLjczIDAgMCAxLTEuOTIgMiA4LjM2IDguMzYgMCAwIDEtMS41NS0uMTZ2Mi4yNmwtMS40Ni4yMnYtOGgxLjE2bC4xNC40N2EzLjE1IDMuMTUgMCAwIDEgMS44NC0uNTljMS4xNyAwIDEuNzkuNjcgMS43OSAxLjk0em0tMy40OC42M2E2LjcyIDYuNzIgMCAwIDAgMS4yOS4xNWMuNTMgMCAuNzMtLjI0LjczLS43NXYtMmMwLS40Ni0uMTgtLjcxLS43Mi0uNzFhMi4xMSAyLjExIDAgMCAwLTEuMy41MXpNODEuNzggMTkuNTRoLTguODl2LTUuMzFIOTYuN3Y1LjMxaC04Ljl2MjYuNTNoLTZ6Ii8+CiAgPHBhdGggY2xhc3M9InRleHQiIGZpbGw9IiMwMDAiIGQ9Ik0xMDIuMTkgNDEuNzdhMjQuMzkgMjQuMzkgMCAwIDAgNy4xMi0xLjFsLjkxIDQuNGEyNSAyNSAwIDAgMS04LjU2IDEuNDhjLTcuMzEgMC05Ljg1LTMuMzktOS44NS05VjMxLjRjMC00LjkyIDIuMi05LjA4IDkuNjYtOS4wOHM5LjEzIDQuMzUgOS4xMyA5LjM3djVoLTEzdjEuMmMuMDUgMi43OCAxLjA1IDMuODggNC41OSAzLjg4ek05Ny42NSAzMmg3LjQxdi0xLjE4YzAtMi4yLS42Ny0zLjczLTMuNTQtMy43M3MtMy44NyAxLjUzLTMuODcgMy43M3ptMjguNTQtNC4zM2E0NS42NSA0NS42NSAwIDAgMC02LjE5IDMuMzl2MTVoLTUuODNWMjIuNzloNC45MmwuMzggMi41OGEyNi4wOSAyNi4wOSAwIDAgMSA2LjEyLTMuMDZ6bTE0LjI0IDBhNDUuNjUgNDUuNjUgMCAwIDAtNi4xNyAzLjM5djE1aC01LjgzVjIyLjc5aDQuOTJsLjM4IDIuNThhMjYuMDkgMjYuMDkgMCAwIDEgNi4xMi0zLjA2em0xOS41MSAxOC40aC00Ljc4bC0uNDMtMS41OGExMi43MyAxMi43MyAwIDAgMS02LjkzIDIuMDZjLTQuMjUgMC02LjA3LTIuOTItNi4wNy02LjkzIDAtNC43MyAyLjA2LTYuNTUgNi43OS02LjU1aDUuNTl2LTIuNDRjMC0yLjU4LS43Mi0zLjQ5LTQuNDUtMy40OWEzMi41MyAzMi41MyAwIDAgMC02LjQ1LjcybC0uNzItNC40NWEzMC4zOCAzMC4zOCAwIDAgMSA4LTEuMWM3LjMxIDAgOS40NyAyLjU4IDkuNDcgOC40MXptLTUuODMtOC44aC00LjNjLTEuOTEgMC0yLjQ0LjUzLTIuNDQgMi4yOXMuNTMgMi4zNCAyLjM0IDIuMzRhOS4xOCA5LjE4IDAgMCAwIDQuNC0xLjJ6bTIzLjc1LTE5Ljc5YTE3LjExIDE3LjExIDAgMCAwLTMuMzUtLjM4Yy0yLjI5IDAtMi42MyAxLTIuNjMgMi43N3YyLjkyaDUuOTNsLS4zMyA0LjY0aC01LjU5djE4LjY0aC01LjgzVjI3LjQzaC0zLjczdi00LjY0aDMuNzN2LTMuMjVjMC00LjgzIDIuMjUtNy4yMiA3LjQxLTcuMjJhMTguNDcgMTguNDcgMCAwIDEgNSAuNjd6bTExLjM4IDI5LjA3Yy04IDAtMTAuMTMtNC40LTEwLjEzLTkuMTh2LTUuODhjMC00Ljc4IDIuMTUtOS4xOCAxMC4xMy05LjE4czEwLjEzIDQuNCAxMC4xMyA5LjE4djUuODhjLjAxIDQuNzgtMi4xNSA5LjE4LTEwLjEzIDkuMTh6bTAtMTkuMjdjLTMuMTEgMC00LjMgMS4zOS00LjMgNHY2LjI2YzAgMi42MyAxLjIgNCA0LjMgNHM0LjMtMS4zOSA0LjMtNFYzMS4zYzAtMi42My0xLjE5LTQuMDItNC4zLTQuMDJ6bTI1LjE0LjM5YTQ1LjY1IDQ1LjY1IDAgMCAwLTYuMTcgMy4zOXYxNWgtNS44M1YyMi43OWg0LjkybC4zOCAyLjU4YTI2LjA4IDI2LjA4IDAgMCAxIDYuMTItMy4wNnptMTYuMDIgMTguNFYyOS44MmMwLTEuMjQtLjUzLTEuODYtMS44Ni0xLjg2YTE2LjA4IDE2LjA4IDAgMCAwLTYuMDcgMnYxNi4xMWgtNS44M1YyMi43OWg0LjQ1bC41NyAyYTIzLjMyIDIzLjMyIDAgMCAxIDkuMzQtMi40OCA0LjQyIDQuNDIgMCAwIDEgNC40IDIuNDkgMjIuODMgMjIuODMgMCAwIDEgOS4zNy0yLjQ5YzMuODcgMCA1LjI2IDIuNzIgNS4yNiA2Ljg4djE2Ljg4aC01LjgzVjI5LjgyYzAtMS4yNC0uNTMtMS44Ni0xLjg2LTEuODZhMTUuNDMgMTUuNDMgMCAwIDAtNi4wNyAydjE2LjExeiIvPgogIDxwYXRoIGNsYXNzPSJyZWN0LWRhcmsiIGZpbGw9IiM0MDQwQjIiIGQ9Ik0zNi40IDIwLjJ2MTguOTNsMTYuNC05LjQ2VjEwLjcyTDM2LjQgMjAuMnoiLz4KICA8cGF0aCBjbGFzcz0icmVjdC1saWdodCIgZmlsbD0iIzVDNEVFNSIgZD0iTTE4LjIgMTAuNzJsMTYuNCA5LjQ4djE4LjkzbC0xNi40LTkuNDdWMTAuNzJ6Ii8+CiAgPHBhdGggY2xhc3M9InJlY3QtbGlnaHQiIGZpbGw9IiM1QzRFRTUiIGQ9Ik0wIC4xNXYxOC45NGwxNi40IDkuNDdWOS42MkwwIC4xNXptMTguMiA1MC41M2wxNi40IDkuNDdWNDEuMjFsLTE2LjQtOS40N3YxOC45NHoiLz4KPC9zdmc+Cg==" alt="logo"/>
<img style="width:150px" src="data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPHN2ZyBoZWlnaHQ9IjMxNSIgcHJlc2VydmVBc3BlY3RSYXRpbz0ieE1pZFlNaWQiIHZpZXdCb3g9IjAgMCAyNTYgMzE1IiB3aWR0aD0iMjU2IiB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciPgogPGcgZmlsbD0iIzFhMTkxOCIgdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMCAyODEuODYpIj4KICA8cGF0aCBkPSJtNjcuNTE2OCAzMi4wMDM1Yy0uNTQxNTIgMC0xLjEyNjE3LS4xMzY4NS0xLjUzMjEyLS42ODU4M2wtMTcuMzgzNS0yMi44NjEydjIzLjMxODdoLTMuOTY0MzF2LTI4LjcxNDJjMC0xLjE0MjUzLjk0NTkyLTIuMDU3MSAyLjAyNzgtMi4wNTcxLjYyOTcxIDAgMS4xNzA4NC4xODI2IDEuNTc0ODUuNzMxNThsMTcuMzM5NiAyMi44MTU5di0yMy4yMjc2aDMuOTYzOTJ2MjguNjY4MWMwIDEuMTg5MDctLjk0NTkyIDIuMDExNzUtMi4wMjYyNSAyLjAxMTc1Ii8+CiAgPHBhdGggZD0ibTEwMC4zMDYgMzIuMjc4Yy0zLjk2Mjc2IDAtOC4xMDY5My0uODIzNDctMTEuOTgwMy0yLjI4NTg0bC45NDYzMS0zLjI5MjdjMy41NTc5NyAxLjE0MzMyIDcuNDMwOTkgMS45NjYzOSAxMS4wMzQgMS45NjYzOSA0Ljk5OTU4IDAgNy42MTE2My0xLjc4MzQgNy42MTE2My00LjI5NzU5IDAtMi4yODY2My0yLjAyNzQxLTMuNDI5NTYtOS4wMDgxNy02LjcyMTg3LTYuOTgwNzYtMy4yOTE5Mi05LjcyNzIyLTUuMzk0NzctOS43MjcyMi05LjUxMDU1IDAtNS4xNjU2MyAzLjk2Mjc2LTcuMjcwMDYgMTEuNDM4NC03LjI3MDA2IDMuMTA4MTMgMCA3Ljg4MTYyLjY0MDg3IDEwLjYzIDEuNDYzOTVsLS42MzA4NyAzLjM4MzAyYy0zLjAxODM5LS43MzExOS02LjgwMDUxLTEuMjM0MDItOS45MDg2NC0xLjIzNDAyLTUuMjY4MzkgMC03LjQzMDYgMS4wMDUyOC03LjQzMDYgMy41MjA2NiAwIDIuNDY4NDQgMS41NzU2MiAzLjUyMDI2IDguOTYxOTQgNi45NDk4MiA3Ljc5MTg4IDMuNjEyMTYgOS43NzM0NSA1LjQ0MTMgOS43NzM0NSA5LjE4OTkyIDAgNS40NDE3LTUuMTM1MTUgOC4xMzg4OC0xMS43MSA4LjEzODg4Ii8+CiAgPHBhdGggZD0ibTEzMC43OTggMS4zMjM2N2g0LjA5ODMzdjMwLjQ1MTFoLTQuMDk4MzN6Ii8+CiAgPHBhdGggZD0ibTE2OS43NTggMTcuOTY2OWgtMTAuMTc5OHYxMC4zMzRoMTAuMTc5OGMzLjQ2NzQ2IDAgNS41ODQyMi0yLjE5NTE0IDUuNTg0MjItNS4yNTkxIDAtMi44ODA1Ny0yLjIwNjUtNS4wNzQ5Mi01LjU4NDIyLTUuMDc0OTJtLTEuOTgyNzQtMTMuMTY4NWgtOC4xOTcwNXY5LjczOTI5aDguMTk3MDVjMy4yODgzOCAwIDUuNjc1MTItMi4xMDM2NCA1LjY3NTEyLTUuMDI5NTcgMC0yLjg4MDU3LTIuMDcyMDgtNC43MDk3Mi01LjY3NTEyLTQuNzA5NzJtMi4wMjc0MSAyNi45NzY2aC0xMi4yNDk5Yy0xLjE3MTYyIDAtMi4wNzI0Ny0uOTE0OTctMi4wNzI0Ny0yLjA1NzV2LTI2LjMzNjFjMC0xLjA5Nzk2LjkwMDg2LTIuMDU3NSAyLjA3MjQ3LTIuMDU3NWgxMC4xMzMyYzYuMjE1MDkgMCA5LjkwNzg2IDMuMDYzMTcgOS45MDc4NiA3Ljg2NDM5IDAgMi42MDU2OS0xLjUzMTM0IDUuMDI5MTctMy44NzM4IDYuNDQ2NTkgMy40Njk0IDEuMDUxODIgNS44MDk5MiAzLjkzMiA1LjgwOTkyIDcuNDA2OTEgMCA0Ljg0NjU3LTQuMDA3NDMgOC43MzMyMi05LjcyNzIyIDguNzMzMjIiLz4KICA8cGF0aCBkPSJtMTk5LjIxMiAzMS43NzUxYy0xLjEyNDIyIDAtMi4wMjU0Ny0uOTYwMzItMi4wMjU0Ny0yLjA1NzV2LTI4LjM5MzZoNC4wOTc1NXYyNi43NDc5aDE2LjMwNHYzLjcwMzI2aC0xOC4zNzYxeiIvPgogIDxwYXRoIGQ9Im0yNDUuNTI2IDMyLjI3OGMtOC4zNzczIDAtMTMuNDIxNS0zLjEwODkyLTEzLjQyMTUtOS4zNzI5MSAwLTIuOTcyMDcgMS42NjY5MS01LjgwNjkgNC45MDk4NC03LjEzMjgxLTIuNjEyNDQtMS42NDYxNi0zLjk2MzE0LTMuOTc4MTQtMy45NjMxNC02LjUzODQ4IDAtNS42NjkyNiA0LjM2OTg3LTguMzY4MDIgMTIuNTY1OC04LjM2ODAyIDIuNzQ3NjMgMCA2LjYyMDI2LjMyMDYzIDkuODYzNTggMS4wNTI2MWwtLjQ1MTAxIDMuMzgzMDJjLTMuNDIyMDEtLjU0ODk4LTYuNjIxMDQtLjg2ODA0LTkuNzI4MzktLjg2ODA0LTUuMzE0NjIgMC04LjE1MjM4IDEuNDYyMzctOC4xNTIzOCA0Ljk4MzQzIDAgMi43ODk0NyAyLjYxMjgzIDQuOTgzODIgNi4wODE0NiA0Ljk4MzgyaDcuMDI1MDRjLjk5MDk4IDAgMS43NTYyNi43NzczMyAxLjc1NjI2IDEuNzM3MjYgMCAxLjAwNTY4LS43NjUyOCAxLjc4MzAxLTEuNzU2MjYgMS43ODMwMWgtNy41NjUwMWMtMy45NjQ3IDAtNi40ODU0NiAxLjk2NTYxLTYuNDg1NDYgNC45ODQyMSAwIDQuNDM0ODQgNC4wOTgzMyA1Ljc2MDc1IDkuMjMyMzIgNS43NjA3NSAyLjc5MjY5IDAgNi41NzQ0Mi0uMzY0OCA5LjYzNjcxLTEuMDk2NzhsLjU4Njk3IDMuMzM3MjdjLTIuOTI4MjcuODIzNDctNi43NTcgMS4zNzE2Ni0xMC4xMzQ3IDEuMzcxNjYiLz4KICA8cGF0aCBkPSJtMTQuMTM4IDcuMDM0NyA3LjE3NzcxIDE3Ljk4NDMtMTAuODQwNi04LjY2OTMzIDMuNjYyODYtOS4zMTQ5M3ptMTIuNzUxNCAyMi4xMjc3LTExLjAzOTktMjYuOTc0NmMtLjMxNTA1LS43NzczMy0uOTQ1OTItMS4xODkwNy0xLjcxMTU5LTEuMTg5MDdzLTEuNDQxMjEuNDExNzQtMS43NTYyNiAxLjE4OTA3bC0xMi4xMTc5IDI5LjU4NzRoNC4xNDQ1Nmw0Ljc5NzU3LTEyLjE5ODMgMTQuMzE0MiAxMS43NDA4Yy41NzU3MS40NzIwOC45OTA5OC42ODU4MyAxLjUzMjEyLjY4NTgzIDEuMDgwMzMgMCAyLjAyNjI1LS44MjI2OCAyLjAyNjI1LTIuMDExMzUgMC0uMTkyODUtLjA2Nzk4LS40OTk2OC0uMTg5MTgtLjgyOTc4eiIvPgogPC9nPgogPHBhdGggZD0ibTI1NS44NzkgMTI3Ljg2OGMwIDcwLjQ1NTEtNTcuMTEwMSAxMjcuNTY1LTEyNy41NjYgMTI3LjU2NS03MC40NTAxIDAtMTI3LjU2Ni01Ny4xMDk2LTEyNy41NjYtMTI3LjU2NSAwLTcwLjQ1MDEgNTcuMTE2MS0xMjcuNTY2IDEyNy41NjYtMTI3LjU2NiA3MC40NTYxIDAgMTI3LjU2NiA1Ny4xMTYxIDEyNy41NjYgMTI3LjU2NiIgZmlsbD0iIzFhMTkxOCIvPgogPHBhdGggZD0ibTEzMC40NiA3OC4yMjg5IDMzLjAxMTYgODEuNDc2My00OS44NjM1LTM5LjI3NzggMTYuODUxOS00Mi4xOTg0em01OC42NDQ1IDEwMC4yNDUtNTAuNzc4Ni0xMjIuMjAyYy0xLjQ0OTUyLTMuNTI0MzYtNC4zNDgwNy01LjM4OTI2LTcuODY1OTEtNS4zODkyNi0zLjUyNDM2IDAtNi42MzM4NiAxLjg2NDg5LTguMDgzMzkgNS4zODkyNmwtNTUuNzMyOSAxMzQuMDRoMTkuMDY1M2wyMi4wNjIzLTU1LjI2NTMgNjUuODM4OSA1My4xODk5YzIuNjQ3OTIgMi4xNDExNCA0LjU1ODUyIDMuMTA5NSA3LjA0MjIgMy4xMDk1IDQuOTczODkgMCA5LjMyMTQ2LTMuNzI4NzggOS4zMjE0Ni05LjExMTAxIDAtLjg3NTk0LS4zMDkzOS0yLjI2NjItLjg2OTQxLTMuNzYxNDN6IiBmaWxsPSIjZmZmIi8+Cjwvc3ZnPgo=" alt="logo"/>

## Provisionner, configurer, vérifier, détruire

Bloc 11 — CL-IAC — Jour 7 (jour 48 du cursus)

---

<style scoped>
div{ font-size:15px }
</style>

## Objectifs de la journée

<div>

À la fin de la journée, vous saurez :

- Trancher **qui fait quoi** : Terraform, cloud-init ou Ansible — avec un tableau de décision, pas au feeling.
- Relier les deux outils par l'inventaire, de deux façons :
  - **inventaire dynamique AWS** (plugin `amazon.aws.aws_ec2` : filtres par tags, `keyed_groups`) ;
  - **génération d'inventaire** depuis les outputs Terraform — et choisir entre les deux.
- Dérouler la **chaîne complète** : Terraform crée le réseau + 2 EC2 taguées → Ansible les configure avec les rôles d'hier → `curl` vérifie → `destroy`.
- Situer `serial` et `any_errors_fatal` (stratégie d'exécution, en survol).
- Savoir **ce qu'on ne fait PAS** avec Ansible — et pourquoi K8s arrive au bloc suivant.

L'après-midi est un atelier : `tp/11-cl-iac/tp-chaine-iac.md`. Et en fin de journée : **quiz de synthèse du bloc IaC entier** (Terraform + Ansible).

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Plan de la journée

<div>

1. **Qui fait quoi** — provisionner vs configurer, cloud-init au milieu.
2. **Relier les deux** — inventaire dynamique `aws_ec2` (voie A).
3. **Relier les deux** — inventaire généré par Terraform (voie B), comparaison.
4. **Atelier fil rouge** — la chaîne complète sur AWS (TP guidé).
5. **Stratégie d'exécution** — `serial`, `any_errors_fatal` (survol).
6. **Les limites** — ce qu'Ansible ne doit pas faire ; cap sur le TP4 et les conteneurs.
7. Récap + **quiz de synthèse du bloc IaC**.

</div>

---

<!-- _class: lead -->

# 1. Qui fait quoi

## Trois outils touchent la machine — un seul doit posséder chaque tâche

---

<style scoped>
div{ font-size:22px }
</style>

## La chaîne cible du jour

<div>

<figure>
<svg viewBox="0 0 640 220" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <defs><marker id="c7" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <rect x="20" y="45" width="170" height="90" rx="8" fill="#5C4EE5"/>
  <text x="105" y="66" fill="#fff" text-anchor="middle" font-weight="bold">TERRAFORM</text>
  <text x="105" y="86"  fill="#fff" text-anchor="middle" font-size="11">provisionner</text>
  <text x="105" y="104" fill="#fff" text-anchor="middle" font-size="11">VPC, SG, 2× EC2</text>
  <text x="105" y="122" fill="#fff" text-anchor="middle" font-size="11">tags Role=web</text>
  <rect x="245" y="45" width="170" height="90" rx="8" fill="#4caf82"/>
  <text x="330" y="66" fill="#fff" text-anchor="middle" font-weight="bold">ANSIBLE</text>
  <text x="330" y="86"  fill="#fff" text-anchor="middle" font-size="11">configurer (SSH)</text>
  <text x="330" y="104" fill="#fff" text-anchor="middle" font-size="11">inventaire dynamique</text>
  <text x="330" y="122" fill="#fff" text-anchor="middle" font-size="11">roles: base·stockline·nginx</text>
  <rect x="470" y="45" width="150" height="90" rx="8" fill="#438ecc"/>
  <text x="545" y="66" fill="#fff" text-anchor="middle" font-weight="bold">VOUS</text>
  <text x="545" y="90"  fill="#fff" text-anchor="middle" font-size="11">curl /sante</text>
  <text x="545" y="110" fill="#fff" text-anchor="middle" font-size="11">sur les 2 IP</text>
  <line x1="190" y1="90" x2="241" y2="90" stroke="#6165ab" stroke-width="2" marker-end="url(#c7)"/>
  <text x="215" y="80" text-anchor="middle" fill="#33404a" font-size="10">tags</text>
  <line x1="415" y1="90" x2="466" y2="90" stroke="#6165ab" stroke-width="2" marker-end="url(#c7)"/>
  <text x="440" y="80" text-anchor="middle" fill="#33404a" font-size="10">SSH</text>
  <rect x="200" y="172" width="240" height="36" rx="8" fill="#d1495b"/>
  <text x="320" y="195" fill="#fff" text-anchor="middle" font-weight="bold">terraform destroy (teardown)</text>
  <line x1="105" y1="135" x2="240" y2="180" stroke="#b8c4cf" stroke-width="2" stroke-dasharray="5 4" marker-end="url(#c7)"/>
  <text x="545" y="150" text-anchor="middle" fill="#33404a" font-size="10">le state ne bouge pas</text>
</svg>
<figcaption>La chaîne complète : Terraform provisionne, Ansible configure, puis teardown</figcaption>
</figure>

Ansible ne crée **aucune** ressource cloud ; Terraform n'installe **aucun** paquet. Chaque tâche a UN propriétaire.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le tableau de décision

<div>

| Tâche | Terraform | cloud-init | Ansible |
|---|:---:|:---:|:---:|
| Créer VPC, SG, EC2, RDS, S3 | ✅ | — | ❌ (possible, à ne pas faire) |
| Amorcer la machine au 1er boot (SSH prêt, hostname) | — | ✅ | — |
| Installer paquets, utilisateurs, durcissement | ❌ | ⚠️ possible | ✅ |
| Déployer/mettre à jour une application | ❌ | ❌ | ✅ |
| Fichiers de conf qui évoluent (nginx, systemd) | ❌ | ❌ | ✅ |
| Redémarrer un service après changement de conf | ❌ | ❌ | ✅ (handler) |
| Détruire l'infrastructure | ✅ | — | ❌ |

Règles de partage :

- **Terraform** possède tout ce qui a un cycle de vie côté **API cloud** (create/destroy).
- **cloud-init** (`user_data`, vu au CL-AWS1 J2) : l'**amorçage du premier boot uniquement** — il ne repasse **jamais**.
- **Ansible** possède tout ce qui **évolue pendant la vie** de la machine : rejouable, versionné, vérifiable.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## cloud-init vs Ansible : le critère qui tranche

<div>

Question à se poser : **« devrai-je re-appliquer cette configuration plus tard ? »**

- **Non, c'est du premier boot** (attendre le réseau, poser une clé, définir le hostname) → cloud-init.
- **Oui, ça évoluera** (version de l'app, conf nginx, liste des ports, utilisateurs) → Ansible.

Pourquoi ne pas tout mettre dans cloud-init, puisqu'il « marche » ?

- il ne s'exécute **qu'une fois** : toute mise à jour exige de **détruire/recréer** l'instance ;
- pas de `--check`, pas de `changed=0`, pas de diff : aucun retour d'état ;
- un script de 200 lignes en user_data = le script bash non rejouable du J5, déguisé.

Notre choix pour l'atelier : **cloud-init minimal** (rien à faire : les AMI Ubuntu sont prêtes — SSH + Python présents), **tout le reste en Ansible**. Le user_data restera vide.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## L'anti-pattern à savoir refuser : le provisioner Terraform

<div>

Terraform *peut* exécuter des commandes dans la machine (`provisioner "remote-exec"`) voire lancer Ansible à la fin d'un `apply`. La documentation HashiCorp elle-même le classe en **dernier recours**. Pourquoi refuser :

- le provisioner ne s'exécute qu'**à la création** de la ressource — même défaut que cloud-init : jamais rejoué, dérive garantie ;
- s'il échoue, la ressource est marquée *tainted* : état à moitié construit, apply suivant chaotique ;
- il **couple** les deux cycles de vie : impossible de reconfigurer sans re-provisionner.

La bonne articulation est **lâche** : Terraform pose des **tags**, Ansible les **découvre**. Chaque outil garde son cycle, son rythme, sa preuve. C'est exactement ce que le TP4 orchestrera en pipeline : deux étapes distinctes, pas un outil qui appelle l'autre.

</div>

---

<!-- _class: lead -->

# 2. Relier les deux — voie A

## L'inventaire dynamique aws_ec2

<figure>
<svg viewBox="0 0 600 190" xmlns="http://www.w3.org/2000/svg" font-family="sans-serif" font-size="12">
  <defs><marker id="i7" markerWidth="10" markerHeight="10" refX="8" refY="3" orient="auto">
    <path d="M0,0 L8,3 L0,6 Z" fill="#6165ab"/></marker></defs>
  <rect x="20" y="30" width="150" height="42" rx="6" fill="#438ecc"/><text x="95" y="50" fill="#fff" text-anchor="middle">EC2 web-1</text><text x="95" y="66" fill="#fff" text-anchor="middle" font-size="10">Role=web</text>
  <rect x="20" y="110" width="150" height="42" rx="6" fill="#438ecc"/><text x="95" y="130" fill="#fff" text-anchor="middle">EC2 web-2</text><text x="95" y="146" fill="#fff" text-anchor="middle" font-size="10">Role=web</text>
  <rect x="240" y="70" width="130" height="46" rx="8" fill="#6165ab"/>
  <text x="305" y="90" fill="#fff" text-anchor="middle" font-weight="bold">plugin aws_ec2</text>
  <text x="305" y="108" fill="#fff" text-anchor="middle" font-size="10">keyed_groups</text>
  <rect x="440" y="70" width="140" height="46" rx="8" fill="#4caf82"/>
  <text x="510" y="90" fill="#fff" text-anchor="middle" font-weight="bold">groupe « web »</text>
  <text x="510" y="108" fill="#fff" text-anchor="middle" font-size="10">hosts: web</text>
  <line x1="170" y1="51"  x2="236" y2="82"  stroke="#6165ab" stroke-width="2" marker-end="url(#i7)"/>
  <line x1="170" y1="131" x2="236" y2="104" stroke="#6165ab" stroke-width="2" marker-end="url(#i7)"/>
  <line x1="370" y1="93" x2="436" y2="93" stroke="#6165ab" stroke-width="2" marker-end="url(#i7)"/>
  <text x="300" y="175" text-anchor="middle" fill="#33404a" font-size="12">le tag Role=web devient le groupe que site.yml cible déjà</text>
</svg>
<figcaption>L'inventaire dynamique : les tags EC2 sont transformés en groupes Ansible</figcaption>
</figure>

---

<style scoped>
div{ font-size:15px }
</style>

## Le problème de l'inventaire statique face au cloud

<div>

Hier, votre inventaire listait UNE VM à IP fixe. Sur AWS :

- les IP publiques **changent** à chaque stop/start ;
- les instances **naissent et meurent** (Auto Scaling au CL-AWS1 J6…) ;
- personne ne veut maintenir un fichier d'IP à la main — c'est la définition même du travail à automatiser.

Renversement de perspective : au lieu d'écrire la liste des machines, on décrit **comment les trouver**. Le plugin d'inventaire **interroge l'API EC2 à chaque exécution** :

```text
ansible-playbook  ->  plugin aws_ec2  ->  API AWS : « qui a le tag
                                           Projet=stockline, running ? »
                  <-  liste d'hôtes + groupes construits à l'instant T
```

Prérequis : collection `amazon.aws`, `boto3`/`botocore` dans le Python d'Ansible, identifiants AWS configurés (les mêmes que Terraform).

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Outiller la voie A sur votre poste (à faire avant le TP)

<div>

Trois briques, côté **poste de contrôle** uniquement (rien côté serveurs) :

```bash
# 1. La collection qui contient le plugin (déjà dans requirements.yml)
ansible-galaxy collection install -r requirements.yml

# 2. Le SDK AWS pour Python, DANS le Python qu'utilise Ansible
pipx inject ansible boto3 botocore        # installation pipx
# (venv : ~/.venvs/ansible/bin/pip install boto3 botocore)

# 3. Des identifiants AWS valides dans le shell courant
aws sts get-caller-identity               # doit répondre avec votre compte
```

Le piège classique : boto3 installé **dans le mauvais Python** (celui du
système, pas celui d'Ansible) → `Failed to import the required Python
library (botocore or boto3)`. Le message dit QUEL interpréteur a cherché :
lisez-le.

En attendant un poste réparé : la **voie B** (section suivante) fonctionne sans aucune de ces briques.

</div>

---

<style scoped>
div{ font-size:13px }
</style>

## inventaires/aws_ec2.yml, ligne par ligne

<div>

```yaml
# Le nom du fichier DOIT finir par aws_ec2.yml — sinon plugin non reconnu
plugin: amazon.aws.aws_ec2

regions:
  - eu-west-3                      # Paris, comme tout le bloc

filters:                           # filtrage CÔTÉ API : ne ramène que…
  tag:Projet: stockline            # …les instances du projet
  instance-state-name: running     # …allumées (stopped = invisibles)

hostnames:                         # nom affiché pour chaque hôte :
  - tag:Name                       # le tag Name (lisible)…
  - dns-name                       # …sinon le DNS public

keyed_groups:                      # GROUPES construits depuis les tags :
  - key: tags.Role                 #   Role=web        -> groupe « web »
    separator: ""                  #   (pas de préfixe)
  - key: tags.Environnement        #   Environnement=formation
    prefix: env                    #                   -> « env_formation »

compose:                           # variables calculées par hôte :
  ansible_host: public_ip_address  #   se connecter via l'IP publique
```

**`keyed_groups` est la clé de voûte** : le tag `Role=web` posé par Terraform devient le groupe `web` — celui que `site.yml` cible déjà (`hosts: web`). Rien à changer dans les rôles.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Inspecter avant d'exécuter : ansible-inventory

<div>

Toujours regarder ce que le plugin découvre **avant** de lancer un playbook :

```bash
ansible-inventory -i inventaires/aws_ec2.yml --graph
```

```text
@all:
  |--@ungrouped:
  |--@aws_ec2:
  |  |--iab-stockline-web-1
  |  |--iab-stockline-web-2
  |--@web:
  |  |--iab-stockline-web-1
  |  |--iab-stockline-web-2
  |--@env_formation:
  |  |--iab-stockline-web-1
  |  |--iab-stockline-web-2
```

- `@aws_ec2` : groupe automatique du plugin (tout ce qu'il a trouvé).
- `@web`, `@env_formation` : **vos** `keyed_groups`, construits depuis les tags.
- `--list` au lieu de `--graph` : le détail JSON (dont `ansible_host` calculé).

L'exercice 7.2 vous donnera une config et des instances : à vous de **prédire** ce graphe.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Ce que ça change côté Terraform : les tags deviennent une interface

<div>

```hcl
resource "aws_instance" "web" {
  count = 2
  # ...
  tags = {
    Name = "${var.prefixe}-stockline-web-${count.index + 1}"
    Role = "web"                     # <- lu par keyed_groups
  }
}

provider "aws" {
  default_tags {
    tags = {
      Projet        = "stockline"   # <- lu par filters
      Environnement = "formation"   # <- lu par keyed_groups
    }
  }
}
```

Les tags ne sont plus de la décoration : ils sont le **contrat d'interface** entre Terraform et Ansible. Un tag `Role` mal orthographié = instance jamais configurée — silencieusement. D'où le réflexe `ansible-inventory --graph` après chaque `apply`.

</div>

---

<!-- _class: lead -->

# 3. Relier les deux — voie B

## Générer l'inventaire depuis Terraform

---

<style scoped>
div{ font-size:13px }
</style>

## Terraform écrit l'inventaire lui-même

<div>

Autre approche : Terraform **connaît** les IP qu'il vient de créer — il peut écrire un inventaire statique à chaque `apply` (ressource `local_file` + `templatefile`, vues au J2) :

```hcl
# inventaire.tf (projet terraform-j7)
resource "local_file" "inventaire_ansible" {
  filename = "${path.module}/../ansible/inventaires/terraform.yml"
  content = templatefile("${path.module}/templates/inventaire.tpl", {
    noms = aws_instance.web[*].tags.Name
    ips  = aws_instance.web[*].public_ip
  })
}
```

```text
# templates/inventaire.tpl
all:
  children:
    web:
      hosts:
%{ for index, ip in ips ~}
        ${noms[index]}:
          ansible_host: ${ip}
%{ endfor ~}
      vars:
        ansible_user: ubuntu
```

Après `terraform apply` : `inventaires/terraform.yml` existe, à jour, lisible. `ansible-playbook -i inventaires/terraform.yml site.yml` — aucun boto3 requis.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Voie A vs voie B : avantages et inconvénients

<div>

| | **Voie A — plugin aws_ec2** | **Voie B — fichier généré** |
|---|---|---|
| Source de vérité | l'API AWS, **en direct** | le state, **à l'instant de l'apply** |
| Dépendances côté Ansible | boto3 + identifiants AWS | aucune |
| Machine détruite hors Terraform | disparaît de l'inventaire | reste → erreur SSH au run |
| Machine créée hors state (autre équipe) | découverte si bien taguée | invisible |
| Lisibilité / debug | `--graph` nécessaire | fichier YAML lisible, diffable |
| Plusieurs states / équipes | les tags fédèrent tout | un fichier par state |
| Usage typique | production, parc vivant | démo, CI simple, mono-projet |

En résumé : **voie A quand le parc vit** (c'est la réalité en entreprise, et notre voie principale aujourd'hui) ; **voie B quand la simplicité prime** et que Terraform est l'unique créateur de machines. Le TP guidé fait pratiquer les deux — vous argumenterez ce choix au TP4.

</div>

---

<!-- _class: lead -->

# 4. L'atelier fil rouge

## La chaîne complète, de zéro à /sante — puis à zéro

---

<style scoped>
div{ font-size:22px }
</style>

## Architecture cible de l'atelier

<div>

```text
                    VPC 10.42.0.0/16 (eu-west-3)
  +--------------------------------------------------------------+
  |   sous-réseau public 10.42.1.0/24            IGW             |
  |                                                |             |
  |   +---------------------+  +---------------------+          |
  |   | EC2 web-1 (t3.micro)|  | EC2 web-2 (t3.micro)|          |
  |   | Role=web            |  | Role=web            |          |
  |   | nginx :80           |  | nginx :80           |          |
  |   |   -> uvicorn :8000  |  |   -> uvicorn :8000  |          |
  |   +---------------------+  +---------------------+          |
  |        SG : 22 depuis IP salle, 80 depuis partout            |
  +--------------------------------------------------------------+
            ^                                    ^
            | Terraform (apply/destroy)          | Ansible (SSH)
            +---------- votre poste -------------+
```

Variante **allégée** du projet J3 : pas d'ALB, pas de RDS — aujourd'hui, c'est la **chaîne** qu'on apprend, pas l'architecture.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Le déroulé (celui du TP guidé)

<div>

```bash
# 1. PROVISIONNER (projet code/11-cl-iac/terraform-j7/)
cp terraform.tfvars.exemple terraform.tfvars   # prefixe, clé, IP admin
terraform init && terraform plan               # 8 ressources
terraform apply

# 2. DÉCOUVRIR (projet code/11-cl-iac/ansible/)
ansible-inventory -i inventaires/aws_ec2.yml --graph   # les 2 EC2 ? groupe web ?
ansible -i inventaires/aws_ec2.yml web -m ping

# 3. CONFIGURER — les rôles d'hier, SANS modification
ansible-playbook -i inventaires/aws_ec2.yml site.yml --ask-vault-pass
ansible-playbook -i inventaires/aws_ec2.yml site.yml --ask-vault-pass  # changed=0

# 4. VÉRIFIER
curl http://$(terraform output -json ips_publiques | jq -r '.[0]')/sante
# {"statut":"ok","base":"accessible"}   — idem IP n°2

# 5. DÉTRUIRE (teardown OBLIGATOIRE)
terraform destroy                              # 8 ressources détruites
```

💰 **Coût** : 2 × t3.micro ≈ 0 € en free-tier, mais **une instance oubliée ≈ 8 €/mois**. La séance ne se termine pas avant le `destroy` vérifié.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Ce qui doit vous frapper dans cet atelier

<div>

1. **`site.yml` n'a pas changé d'une ligne** depuis hier. VM Multipass locale ou EC2 à Paris : mêmes rôles, même playbook — seul l'**inventaire** change. C'est la définition d'un code de configuration bien découplé.

2. **Les tags font tout le travail de liaison.** Terraform tague, le plugin regroupe, `hosts: web` cible. Aucun fichier d'IP, aucun copier-coller.

3. **La preuve reste la même** : second run `changed=0`, sur les 2 machines. L'idempotence ne dépend pas de l'endroit où tournent les machines.

4. **La chaîne est jetable et reconstructible** : `destroy` puis re-`apply` + re-`ansible-playbook` = le même service, à l'identique, en quelques minutes. C'est ça, l'infrastructure as code de bout en bout — et c'est ce que note la grille du TP4.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## 💻 Démo 7.1 puis 🧪 TP guidé

<div>

**Démo 7.1 — La chaîne Terraform + Ansible** — `demos/11-cl-iac/demo-7-1-chaine-terraform-ansible.md`
Le formateur déroule la chaîne complète en ~30 min commentées : apply, `--graph`, ping, site.yml sur les 2 EC2, curl, sabotage d'une conf → re-run qui répare, destroy. Regardez **l'ordre des gestes** et les points de contrôle.

**TP guidé (non noté) — l'après-midi, en autonomie** — `tp/11-cl-iac/tp-chaine-iac.md`
Vous refaites la chaîne sur **votre** compte, avec **votre** trigramme : 6 étapes, 8 points de contrôle, les deux voies d'inventaire, dépannage courant fourni, teardown vérifié en dernier point de contrôle.

C'est la répétition générale du **TP4** (3 jours, noté) : la même chaîne, orchestrée par un pipeline GitHub Actions.

</div>

---

<!-- _class: lead -->

# 5. Stratégie d'exécution

## serial, any_errors_fatal — en survol

---

<style scoped>
div{ font-size:15px }
</style>

## Déployer sur un parc sans le casser en entier

<div>

Par défaut, Ansible traite tous les hôtes **en parallèle**, tâche par tâche. Sur 2 machines de formation : parfait. Sur 20 serveurs de production derrière un ALB : un playbook défectueux casse **tout le parc d'un coup**.

```yaml
- name: Configurer les serveurs web StockLine
  hosts: web
  serial: 1              # une machine à la fois (ou "25%", ou [1, 5, 10])
  any_errors_fatal: true # le 1er échec arrête TOUT le déploiement
```

- **`serial`** : découpe en vagues — la vague 1 échoue ? les suivantes ne sont jamais touchées. C'est le déploiement progressif (le *rolling update*, que Kubernetes fera nativement au bloc suivant).
- **`any_errors_fatal`** : sans lui, Ansible continue sur les hôtes sains et vous laisse un parc **à moitié déployé** — l'état le plus difficile à rattraper.

À notre échelle (2 machines), on les lit plus qu'on ne les règle — mais le `any_errors_fatal: true` est déjà dans `site.yml`, et le TP4 vous demandera de justifier ces choix.

</div>

---

<!-- _class: lead -->

# 6. Les limites

## Ce qu'on ne fait PAS avec Ansible

---

<style scoped>
div{ font-size:15px }
</style>

## Savoir s'arrêter : les frontières d'Ansible

<div>

Ansible **peut** techniquement beaucoup — voici ce qu'il ne **doit** pas faire dans une organisation saine :

- **Provisionner le cloud** (des modules `amazon.aws.ec2_instance` existent) : pas de plan préalable digne de ce nom, pas de graphe de dépendances, pas de `destroy` global. C'est le métier de Terraform ; deux outils qui créent des ressources = deux sources de vérité qui divergent.
- **Orchestrer des conteneurs** : redémarrer 30 conteneurs sur 10 machines, répartir la charge, redémarrer ce qui meurt, monter en charge — c'est de la **réconciliation continue**, pas du push ponctuel. Un orchestrateur le fait en boucle, 24h/24 : c'est **Kubernetes**, bloc CL-CONT dès lundi.
- **Servir de plan B au monitoring** : Ansible applique un état quand *on le lance* ; il ne surveille rien entre deux runs. La supervision reste CloudWatch/Azure Monitor (et CL-SECU pour la détection).

Un bon admin cloud se reconnaît autant à l'outil qu'il choisit qu'à celui qu'il **refuse**.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Où vous en êtes — et la suite immédiate

<div>

```text
  CL-IAC (ce bloc)                       CL-TP4 (lundi en huit, 3 j, NOTÉ)
  ┌────────────────────────┐             ┌──────────────────────────────┐
  │ J1-J4  Terraform       │             │ pipeline GitHub Actions :    │
  │ J5     Ansible : bases │   ────>     │  fmt/validate/tflint/lint    │
  │ J6     rôles, vault    │             │  -> plan -> approbation      │
  │ J7     la chaîne       │             │  -> apply -> ansible-playbook│
  └────────────────────────┘             │  -> health check -> (destroy)│
                                         └──────────────────────────────┘
```

Au TP4, **plus personne ne tape `terraform apply` ni `ansible-playbook` à la main** : c'est le pipeline qui enchaîne ce que vous avez fait aujourd'hui manuellement — avec une approbation humaine entre le plan et l'apply, et une revue de code croisée entre équipes.

Tout ce que vous avez produit cette semaine (projet Terraform, rôles, site.yml, vault) est **réutilisé tel quel**. Soignez vos dépôts ce soir : c'est votre matière première.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Check-list avant le TP4 (à valider ce soir)

<div>

Le TP4 démarre lundi en huit — votre matière première, c'est cette semaine :

- [ ] Projet Terraform J1-J4 : `terraform fmt -check`, `validate` et `tflint` passent ; state distant opérationnel ; `.gitignore` correct (pas de tfstate, pas de tfvars personnels commités).
- [ ] Projet Ansible : `ansible-lint` sans erreur ; rejeu de `site.yml` sur votre VM Multipass à **`changed=0`** ; aucun secret en clair (`git log -p | grep -i password` ne remonte rien).
- [ ] Vault : le mot de passe est dans **votre gestionnaire de mots de passe** — pas dans le dépôt, pas sur un post-it.
- [ ] Les deux projets sont **poussés** sur votre dépôt git personnel avec un README à jour.
- [ ] Compte AWS : plus AUCUNE ressource du bloc en vie (vérification du teardown ci-après).

La grille du TP4 note exactement ces réflexes : `changed=0`, secrets protégés, teardown vérifié.

</div>

---

<style scoped>
div{ font-size:15px }
</style>

## Récap : les points clés du jour

<div>

- **Un propriétaire par tâche** : Terraform = cycle de vie cloud ; cloud-init = premier boot uniquement ; Ansible = tout ce qui évolue dans la machine. Provisioners Terraform : dernier recours, refusez le couplage.
- **Voie A** — plugin `aws_ec2` : l'API AWS est la source de vérité ; `filters` par tags, `keyed_groups` transforme `Role=web` en groupe `web`. Réflexe : `ansible-inventory --graph`.
- **Voie B** — `local_file` + `templatefile` : inventaire lisible sans dépendance, mais figé à l'apply. Choix argumenté selon le contexte.
- **Les tags sont l'interface** entre les deux outils — un tag faux = machine jamais configurée, silencieusement.
- Le même `site.yml` a servi la VM locale et les EC2 : le découplage inventaire/rôles, c'est ça.
- `serial` = vagues, `any_errors_fatal` = pas de parc à moitié déployé.
- Teardown **vérifié** : la chaîne n'est complète qu'après le destroy.

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz de synthèse IaC — questions 1 et 2

<div>

*Ce quiz porte sur tout le bloc : Terraform (J1-J4) et Ansible (J5-J7).*

**Question 1** — Dans la chaîne complète, quelle est la répartition correcte des responsabilités ?

- A. Terraform installe nginx, Ansible crée le VPC
- B. Terraform crée VPC/SG/EC2, Ansible configure l'intérieur des machines (paquets, services, app)
- C. Ansible crée les EC2 puis Terraform les configure
- D. cloud-init remplace les deux outils sur AWS

**Question 2** — Quelle commande Terraform montre les changements prévus SANS les appliquer, et quel est son équivalent conceptuel côté Ansible ?

- A. `terraform show` / `ansible-playbook --syntax-check`
- B. `terraform plan` / `ansible-playbook --check --diff`
- C. `terraform validate` / `ansible-playbook --list-tags`
- D. `terraform graph` / `ansible-inventory --graph`

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz de synthèse IaC — questions 3 et 4

<div>

**Question 3** — Concernant l'état : quelle affirmation est vraie ?

- A. Terraform et Ansible stockent tous deux un fichier de state qu'il faut héberger dans S3
- B. Terraform maintient un state (localement ou dans S3 avec verrouillage) ; Ansible n'a pas de state et interroge l'état réel à chaque run
- C. Ansible stocke son state dans l'inventaire
- D. Le state Terraform est inutile dès qu'on utilise des modules

**Question 4** — Pourquoi le fichier `terraform.tfstate` ne doit-il jamais être commité dans git ?

- A. Il est trop volumineux pour git
- B. Il change de format à chaque version de Terraform
- C. Il peut contenir des attributs sensibles en clair et sa version git divergerait de la réalité partagée
- D. git refuse les fichiers JSON

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz de synthèse IaC — questions 5 et 6

<div>

**Question 5** — Une instance EC2 porte les tags `Projet=stockline` et `Role=web`. Avec le `keyed_groups` suivant, dans quel groupe Ansible atterrit-elle ?

```yaml
keyed_groups:
  - key: tags.Role
    separator: ""
```

- A. `tag_role_web` — B. `web` — C. `role_web` — D. `stockline`

**Question 6** — Quel est le principal INCONVÉNIENT de l'inventaire généré par Terraform (`local_file`) par rapport au plugin `aws_ec2` ?

- A. Il nécessite boto3 sur le poste de contrôle
- B. Il ne peut pas contenir de variables comme `ansible_user`
- C. Il fige la liste à l'instant de l'apply : toute machine créée ou détruite hors de ce state lui échappe
- D. Il est illisible pour un humain

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz de synthèse IaC — questions 7 et 8

<div>

**Question 7** — Vous devez ajouter le paquet `htop` sur les 2 serveurs web déployés ce matin. Quelle est la bonne méthode ?

- A. `ssh` sur chaque machine et `apt install htop`
- B. Ajouter htop dans le user_data et recréer les instances avec Terraform
- C. Ajouter htop à la liste de paquets du rôle `base` et rejouer le playbook
- D. Créer une nouvelle AMI avec htop préinstallé

**Question 8** — À quoi sert le mécanisme `notify` / handler, introuvable dans un script bash ?

- A. À envoyer un e-mail à l'admin à la fin du playbook
- B. À redémarrer un service uniquement si sa configuration a réellement changé, une seule fois par play
- C. À notifier Terraform qu'Ansible a terminé
- D. À relancer automatiquement les tâches en échec

</div>

---

<style scoped>
div{ font-size:14px }
</style>

## Quiz de synthèse IaC — questions 9 et 10

<div>

**Question 9** — Le durcissement sshd doit s'appliquer à un nouveau serveur créé demain par un collègue avec le même code. Où cette logique doit-elle vivre ?

- A. Dans le user_data de l'instance Terraform
- B. Dans le rôle Ansible `base`, appliqué par site.yml à tout hôte du groupe
- C. Dans un script bash documenté dans le wiki
- D. Dans le fichier terraform.tfstate

**Question 10** — En fin de TP, `terraform destroy` affiche `Destroy complete! Resources: 8 destroyed.` Quelle vérification reste indispensable ?

- A. Aucune : le message suffit
- B. Contrôler dans la console (ou par CLI) qu'aucune instance/ressource taguée du projet ne subsiste, région correcte sélectionnée
- C. Supprimer le fichier terraform.tfstate pour effacer les traces
- D. Relancer ansible-playbook pour confirmer que les machines ne répondent plus

*Réponses commentées : guide formateur — correction collective en clôture du bloc.*

</div>

---

<!-- _class: lead -->

# Fin du bloc IaC

## Rendez-vous au TP4

Vous savez désormais **décrire** une infrastructure (Terraform), **décrire** sa configuration (Ansible), **prouver** la convergence (`plan`, `--check`, `changed=0`) et **tout détruire proprement**.

Le TP4 (3 jours, noté) branche cette chaîne sur un pipeline GitHub Actions : validation → plan → approbation → apply → configuration → health check. Vos dépôts de cette semaine sont le point de départ — relisez-les d'ici là.

**Automatiser, superviser, sécuriser.** Un tiers du chemin est fait.
