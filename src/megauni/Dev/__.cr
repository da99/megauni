
module MEGAUNI
  module Dev
    extend self

    def upgrade
      DA_Dev.orange! "=== {{Pulling}} BOLD{{#{DA_Process.new("git remote get-url origin").success!.output.to_s.strip}}}"
      DA_Process.success!("git", "pull".split)

      DA_Dev.orange! "=== {{yarn upgrade}}"
      DA_Process.success!("yarn", "upgrade".split)

      DA_Dev.orange! "=== {{Upgrading}}: crystal shards"
      DA_Dev.deps
      DA_Dev.green! "=== {{Done}}: BOLD{{upgrading}} ==="
    end

  end # === module Dev
end # === module MEGAUNI
