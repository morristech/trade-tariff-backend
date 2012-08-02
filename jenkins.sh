#!/bin/bash -x
bundle install --path "/home/jenkins/bundles/${JOB_NAME}" --deployment

bundle exec rake db:force_close_open_connections
bundle exec rake db:reset

RAILS_ENV=test bundle exec rake ci:setup:rspec spec
RESULT=$?
exit $RESULT
