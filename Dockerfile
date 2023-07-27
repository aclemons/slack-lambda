FROM aclemons/slackware:15.0@sha256:6dcfd273785c24fe1c99507f69a75dbda5f575ccc2321a988dab360b04be2814 as lambda-layers

WORKDIR /tmp
COPY ./extensions/lambda-insights-*.zip .
RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install infozip || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    if [ "$(uname -m)" = "aarch64" ] ; then unzip -q -d /tmp/layer lambda-insights-*arm64*.zip ; else unzip -q -d /tmp/layer lambda-insights-*amd64*.zip ; fi && \
    rm -- *.zip && removepkg infozip


FROM aclemons/slackware:15.0@sha256:6dcfd273785c24fe1c99507f69a75dbda5f575ccc2321a988dab360b04be2814

COPY --from=lambda-layers /tmp/layer /opt


RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install brotli ca-certificates cyrus-sasl curl dcron nghttp2 perl || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    c_rehash && update-ca-certificates

COPY startup.sh /startup.sh

ENTRYPOINT ["/startup.sh"]
