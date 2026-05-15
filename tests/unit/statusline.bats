#!/usr/bin/env bats
# @file statusline.bats
# @brief Behavior tests for home/dot_claude/statusline-command.sh.
#        Pipes fixture JSON into the script (matching Claude Code's runtime contract)
#        and asserts the rendered output contains the expected segments.

load '../test_helpers/load.bash'

STATUSLINE="$DOTFILES_ROOT/home/dot_claude/statusline-command.sh"
FIXTURES="$DOTFILES_ROOT/tests/fixtures/statusline"

@test "renders full payload: model, context, cost, 5h rate limit" {
  run sh "$STATUSLINE" < "$FIXTURES/full-payload.json"
  assert_success
  assert_output --partial 'Opus 4.7'
  assert_output --partial '17%'
  assert_output --partial '$0.42'
  assert_output --partial '5h'
  assert_output --partial '45%'
}

@test "renders full payload: effort segment when .effort.level is present" {
  run sh "$STATUSLINE" < "$FIXTURES/full-payload.json"
  assert_success
  assert_output --partial 'max'
}

@test "minimal payload: succeeds and omits rate-limit / cost / effort segments" {
  run sh "$STATUSLINE" < "$FIXTURES/minimal.json"
  assert_success
  assert_output --partial 'Sonnet 4.6'
  assert_output --partial '5%'
  refute_output --partial '5h'
  refute_output --partial '$'
}

@test "worktree fixture: surfaces the worktree name segment" {
  run sh "$STATUSLINE" < "$FIXTURES/worktree.json"
  assert_success
  assert_output --partial 'feat-experiment'
}
