FROM python:slim

WORKDIR /scripts

COPY scripts-python/ ./

# CMD [ "python", "hello-world.py" ]
# ENTRYPOINT [ "python", "hello-world.py" ]

ENTRYPOINT [ "python"]
CMD [ "hello-world.py" ]