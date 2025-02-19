# syntax=docker/dockerfile:1.13.0@sha256:426b85b823c113372f766a963f68cfd9cd4878e1bcc0fda58779127ee98a28eb

FROM aclemons/slackware:current@sha256:a17c724b83f1cf9a6735eef090bf8c08e6563496ca8341e1ba6e2f052aeca827 AS base

RUN export TERSE=0 && \
    sed -i '/^WGETFLAGS/s/"$/ -q"/' /etc/slackpkg/slackpkg.conf && \
    slackpkg -default_answer=yes -batch=on update && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on upgrade-all || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on install brotli ca-certificates cyrus-sasl curl dcron nghttp2 nghttp3 perl || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    c_rehash && update-ca-certificates && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    touch /var/lib/slackpkg/current

# renovate: datasource=github-releases depName=aws/aws-lambda-runtime-interface-emulator
ARG AWS_LAMBDA_RIE_VERSION=v1.23

RUN if [ "$(uname -m)" = "aarch64" ] ; then curl -o /usr/local/bin/aws-lambda-rie -L "https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/$AWS_LAMBDA_RIE_VERSION/aws-lambda-rie-arm64" ; else curl -o /usr/local/bin/aws-lambda-rie -L "https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/$AWS_LAMBDA_RIE_VERSION/aws-lambda-rie-x86_64" ; fi && \
    chown root:root /usr/local/bin/aws-lambda-rie && chmod 0755 /usr/local/bin/aws-lambda-rie


FROM base AS lambda-layers

ENV EXTENSION_VERSION=1.0.391.0
ENV EXTENSION_CHECKSUM_AMD64=2d297cab0a2fc55b044a314cf4ef08b4c8256fc7124ac3d9ea4de7360af03e3d333ff21b0ab1d0c0063112dc92ee659136cb97f0448e77cd0a0b23c819dfd11c
ENV EXTENSION_CHECKSUM_ARM64=73b4f898b2d610838b9d12e9caf221f29095f75d4ecca02bd8c123b4ca8c124f9da4e7d359d381753fe0464ea1668177a3788afff4f17315fa80a78aa268651a

WORKDIR /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN export TERSE=0 && \
    slackpkg -default_answer=yes -batch=on update && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on upgrade-all || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on install cpio icu4c libarchive libgcrypt libgpg-error libxml2 lua lz4 patchelf rpm sqlite || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    touch /var/lib/slackpkg/current && \
    if [ "$(uname -m)" = "x86_64" ] ; then curl -o /tmp/lambda-insights-extension.rpm -L "https://lambda-insights-extension.s3-ap-northeast-1.amazonaws.com/amazon_linux/lambda-insights-extension.$EXTENSION_VERSION.rpm" ; fi && \
    if [ "$(uname -m)" = "x86_64" ] ; then echo "$EXTENSION_CHECKSUM_AMD64 /tmp/lambda-insights-extension.rpm" | sha512sum --strict --check ; fi && \
    if [ "$(uname -m)" = "aarch64" ] ; then curl -o /tmp/lambda-insights-extension.rpm -L "https://lambda-insights-extension-arm64.s3-ap-northeast-1.amazonaws.com/amazon_linux/lambda-insights-extension-arm64.$EXTENSION_VERSION.rpm" ; fi && \
    if [ "$(uname -m)" = "aarch64" ] ; then echo "$EXTENSION_CHECKSUM_ARM64 /tmp/lambda-insights-extension.rpm" | sha512sum --strict --check ; fi && \
    rpm2cpio < /tmp/lambda-insights-extension.rpm | cpio -imdv && \
    rm -f /tmp/lambda-insights-extension.rpm && \
    if [ "$(uname -m)" = "aarch64" ] ; then patchelf --set-interpreter /lib64/ld-linux-aarch64.so.1 /opt/extensions/cloudwatch_lambda_agent ; fi && \
    removepkg cpio icu4c libgcrypt libarchive libgpg-error libxml2 lua lz4 patchelf rpm sqlite


FROM base

COPY --link --from=lambda-layers /opt /opt
COPY --link --chmod=0755 lambda-entrypoint.sh /lambda-entrypoint.sh
COPY --link --chmod=0755 startup.sh /startup.sh

ENTRYPOINT ["/lambda-entrypoint.sh"]
