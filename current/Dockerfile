# syntax=docker/dockerfile:1.23.0@sha256:2780b5c3bab67f1f76c781860de469442999ed1a0d7992a5efdf2cffc0e3d769

FROM aclemons/slackware:current@sha256:8e268b264439c7a1b549bfaf2bf7b18960240cf2b2bec14edb396c8ba9385b74 AS base

RUN export TERSE=0 && \
    sed -i '/^WGETFLAGS/s/"$/ -q"/' /etc/slackpkg/slackpkg.conf && \
    slackpkg -default_answer=yes -batch=on update && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on upgrade-all || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    EXIT_CODE=0 && { slackpkg -default_answer=yes -batch=on install brotli ca-certificates cyrus-sasl curl dcron nghttp2 nghttp3 ngtcp2 perl || EXIT_CODE=$? ; } && \
    if [ "$EXIT_CODE" -ne 0 ] && [ "$EXIT_CODE" -ne 20 ] ; then exit "$EXIT_CODE" ; fi && \
    c_rehash && update-ca-certificates && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    touch /var/lib/slackpkg/current

# renovate: datasource=github-releases depName=aws/aws-lambda-runtime-interface-emulator
ARG AWS_LAMBDA_RIE_VERSION=v1.35
ENV AWS_LAMBDA_RIE_AMD64_SHA=4fe09c00c74470d5ff54a9ebfeee88c1594c2a8c12c39ed4c763f069efc05b785247481931ca4a8edf30bcf1081e37543f736e3d93fd0648ebf5d08da2b1082b
ENV AWS_LAMBDA_RIE_ARM64_SHA=035c42cab1ea4de4f9b158a94d5d05ca466ca3ac4b45fedbd782d7d3c3a10a3551a6b27e591351686edadd11590af3c96707eea675387d131c78a4c4683007fd

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN \
    if [ "$(uname -m)" = "aarch64" ] ; then curl -o /usr/local/bin/aws-lambda-rie -L "https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/$AWS_LAMBDA_RIE_VERSION/aws-lambda-rie-arm64" ; fi  && \
    if [ "$(uname -m)" = "aarch64" ] ; then printf "%s\t/usr/local/bin/aws-lambda-rie\n" "$AWS_LAMBDA_RIE_ARM64_SHA" | sha512sum -c - ; fi && \
    if [ "$(uname -m)" = "x86_64" ] ; then curl -o /usr/local/bin/aws-lambda-rie -L "https://github.com/aws/aws-lambda-runtime-interface-emulator/releases/download/$AWS_LAMBDA_RIE_VERSION/aws-lambda-rie-x86_64" ; fi && \
    if [ "$(uname -m)" = "x86_64" ] ; then printf "%s\t/usr/local/bin/aws-lambda-rie\n" "$AWS_LAMBDA_RIE_AMD64_SHA" | sha512sum -c - ; fi && \
    chown root:root /usr/local/bin/aws-lambda-rie && chmod 0755 /usr/local/bin/aws-lambda-rie


FROM base AS lambda-layers

ENV EXTENSION_VERSION=1.0.660.0
ENV EXTENSION_CHECKSUM_AMD64=12fa6f55f09b1ab207cae246cfc88ff63c8f858cc45bc56c8111259232e96b133ed43f8205a815e7eed454a084e201d7f80d01c2068bb3070eaccc4a3bfda8d5
ENV EXTENSION_CHECKSUM_ARM64=22b268f85e0453cce8794a116727a123586d06bc662b7960333877b21e3e6a350d68552bdf3dfdab58655592b34b8b23ad9a6dfa2a4c577a52496f66a289979a

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
