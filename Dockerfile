FROM aclemons/slackware:15.0@sha256:f2b12e5053feb1f4a6d5db52468c72ef441d8855da3a9d6d26773cc1f1cb4857 as lambda-layers

WORKDIR /tmp
COPY ./extensions/lambda-insights-*.zip .
RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install infozip || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    unzip -q -d /tmp/layer lambda-insights-*amd64*.zip && \
    rm -- *.zip && removepkg infozip


FROM aclemons/slackware:15.0@sha256:f2b12e5053feb1f4a6d5db52468c72ef441d8855da3a9d6d26773cc1f1cb4857

COPY --from=lambda-layers /tmp/layer /opt

RUN export TERSE=0 && slackpkg -default_answer=yes -batch=on update && EXIT_CODE=0 && \
    slackpkg -default_answer=yes -batch=on install brotli ca-certificates cyrus-sasl curl dcron nghttp2 perl || EXIT_CODE=$? && \
    if [ $EXIT_CODE -ne 0 ] && [ $EXIT_CODE -ne 20 ] ; then exit $EXIT_CODE ; fi && \
    rm -rf /var/cache/packages/* && rm -rf /var/lib/slackpkg/* && \
    c_rehash && update-ca-certificates

COPY startup.sh /startup.sh

ENTRYPOINT ["/startup.sh"]
