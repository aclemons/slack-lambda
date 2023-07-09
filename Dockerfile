FROM aclemons/slackware:15.0@sha256:5a594b9b9d6c28754edfe71de7b59689cb8cc40e39e527399b1cab82e5cd6a91 as lambda-layers

WORKDIR /tmp
COPY ./extensions/lambda-insights-*.zip .
RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install infozip || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    if [ "$(uname -m)" = "aarch64" ] ; then unzip -q -d /tmp/layer lambda-insights-*arm64*.zip ; else unzip -q -d /tmp/layer lambda-insights-*amd64*.zip ; fi && \
    rm -- *.zip && removepkg infozip


FROM aclemons/slackware:15.0@sha256:5a594b9b9d6c28754edfe71de7b59689cb8cc40e39e527399b1cab82e5cd6a91

COPY --from=lambda-layers /tmp/layer /opt

RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install brotli cyrus-sasl curl nghttp2 || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/*

COPY startup.sh /startup.sh

ENTRYPOINT ["/startup.sh"]
