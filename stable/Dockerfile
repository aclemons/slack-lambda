# syntax=docker/dockerfile:1.21.0@sha256:27f9262d43452075f3c410287a2c43f5ef1bf7ec2bb06e8c9eeb1b8d453087bc

FROM aclemons/slackware:15.0@sha256:9b1b9baaaf0bb85bff77d1a350d22b89554e284e8cd7fe635d4b874dd8e33dad AS base

RUN export TERSE=0 && \
    sed -i '/^WGETFLAGS/s/"$/ -q"/' /etc/slackpkg/slackpkg.conf && \
    slackpkg -default_answer=yes -batch=on update && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on upgrade-all || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on install brotli ca-certificates cyrus-sasl curl dcron nghttp2 perl || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    c_rehash && update-ca-certificates && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/*

# renovate: datasource=github-releases depName=aws/aws-lambda-runtime-interface-emulator
ARG AWS_LAMBDA_RIE_VERSION=v1.33

RUN curl -o /usr/local/bin/aws-lambda-rie -L "https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/$AWS_LAMBDA_RIE_VERSION/aws-lambda-rie-x86_64" && \
    chown root:root /usr/local/bin/aws-lambda-rie && chmod 0755 /usr/local/bin/aws-lambda-rie


FROM base AS lambda-layers

ENV EXTENSION_VERSION=1.0.660.0
ENV EXTENSION_CHECKSUM_AMD64=12fa6f55f09b1ab207cae246cfc88ff63c8f858cc45bc56c8111259232e96b133ed43f8205a815e7eed454a084e201d7f80d01c2068bb3070eaccc4a3bfda8d5

WORKDIR /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN export TERSE=0 && \
    slackpkg -default_answer=yes -batch=on update && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on upgrade-all || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on install cpio icu4c libgcrypt libgpg-error lua patchelf rpm sqlite || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    curl -o /tmp/lambda-insights-extension.rpm -L "https://lambda-insights-extension.s3-ap-northeast-1.amazonaws.com/amazon_linux/lambda-insights-extension.$EXTENSION_VERSION.rpm" && \
    echo "$EXTENSION_CHECKSUM_AMD64 /tmp/lambda-insights-extension.rpm" | sha512sum --strict --check && \
    rpm2cpio < /tmp/lambda-insights-extension.rpm | cpio -imdv && \
    rm -f /tmp/lambda-insights-extension.rpm && \
    removepkg cpio icu4c libgcrypt libgpg-error rpm sqlite


FROM base

COPY --link --from=lambda-layers /opt /opt
COPY --link --chmod=0755 lambda-entrypoint.sh /lambda-entrypoint.sh
COPY --link --chmod=0755 startup.sh /startup.sh

ENTRYPOINT ["/lambda-entrypoint.sh"]
