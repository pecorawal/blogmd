FROM docker.io/jekyll/builder

ENV GIT_REPO="https://github.com/mauricioscastro/blog"
ENV WORKDIR="/workdir"

ENTRYPOINT \
  repo_path=`echo $GIT_REPO | sed -e 's;.*/;;g'`; \
  function keep_pulling(){ cd $WORKDIR/$repo_path; while true; do sleep 10; git pull; done; }; \
  cd $WORKDIR; \
  git clone $GIT_REPO; \
  chmod -R a+rwx $WORKDIR; \
  keep_pulling & \
  cd $repo_path; \
  bundle config set path $WORKDIR/bundle; \
  bundle install; \
  bundle exec jekyll serve -d $WORKDIR/site --host "0.0.0.0" --incremental

  

