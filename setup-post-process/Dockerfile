FROM aztec/setup-tools:latest
FROM ubuntu:latest
RUN apt update && apt install -y curl jq python3-pip
RUN pip3 install awscli --upgrade
COPY --from=0 /usr/src/setup-tools/compute_range_polynomial /usr/src/setup-tools/compute_range_polynomial
WORKDIR /usr/src/setup-post-process
COPY . .
CMD ./run