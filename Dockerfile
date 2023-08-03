FROM aclemons/slackware:15.0@sha256:22ff02d779235d415053a732e380e5b73a4c11106b3d1cc7d1fc4cd1c9a0c69b as lambda-layers

WORKDIR /tmp
COPY ./extensions/lambda-insights-*.zip .
RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install infozip || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    unzip -q -d /tmp/layer lambda-insights-*amd64*.zip && \
    rm -- *.zip && removepkg infozip


FROM aclemons/slackware:15.0@sha256:22ff02d779235d415053a732e380e5b73a4c11106b3d1cc7d1fc4cd1c9a0c69b

COPY --from=lambda-layers /tmp/layer /opt

RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install brotli ca-certificates cyrus-sasl curl dcron nghttp2 perl || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    c_rehash && update-ca-certificates

COPY startup.sh /startup.sh

ENTRYPOINT ["/startup.sh"]
