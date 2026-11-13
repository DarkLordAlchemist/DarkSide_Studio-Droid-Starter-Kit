<#
  SessionStart hook (matcher "compact"): right after a compaction, tell EVIE to
  re-ground and save any lesson that survived only in the summary.
  The Local lane gets a one-line version so a smaller context isn't spent on re-reads.
#>
$local = "$env:ANTHROPIC_BASE_URL" -match '127\.0\.0\.1|localhost'
if ($local) {
    $msg = 'Context was just compacted. Continue the current task. If the summary shows a confirmed lesson that will change future behavior, add one line about it to today''s daily note.'
} else {
    $msg = 'Context was just compacted. Before continuing: (1) re-read Vault/VAULT-INDEX.md and Vault/GUARDRAILS.md and the tail of Vault/log.md; (2) SWEEP - from the summary, save any decision, preference or correction that will change future behavior and is not saved yet (why + how + date + source; fix the matching skill if it is about a repeated job) and log it; (3) resume. Keep it short.'
}
@{ hookSpecificOutput = @{ hookEventName = 'SessionStart'; additionalContext = $msg } } | ConvertTo-Json -Compress -Depth 5
exit 0
