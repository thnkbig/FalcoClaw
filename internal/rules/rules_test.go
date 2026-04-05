package rules

import (
	"os"
	"path/filepath"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/stretchr/testify/require"
	"github.com/thnkbig/falcoclaw/internal/models"
)

func TestLoad(t *testing.T) {
	tmpDir := t.TempDir()
	f := filepath.Join(tmpDir, "rules.yaml")
	err := os.WriteFile(f, []byte(testRuleYAML), 0644)
	require.NoError(t, err)
	rules, err := Load(f)
	require.NoError(t, err)
	require.Len(t, rules, 1)
	assert.Equal(t, "test-kill-shell-injection", rules[0].Name)
	assert.True(t, rules[0].DryRun)
}

func TestRuleMatchEvent(t *testing.T) {
	rule := Rule{
		Name: "test-shell-injection",
		Match: Match{
			Rules: []string{"shell_injection", "proc.name equals python"},
		},
		DryRun: false,
	}
	tests := []struct {
		name     string
		ruleName string
		expected bool
	}{
		{"matches shell_injection", "shell_injection", true},
		{"matches python rule", "proc.name equals python", true},
		{"no match", "read_sensitive_file", false},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			result := rule.MatchEvent(&models.Event{Rule: tt.ruleName})
			assert.Equal(t, tt.expected, result)
		})
	}
}

func TestRuleValidation_MissingName(t *testing.T) {
	tmpDir := t.TempDir()
	f := filepath.Join(tmpDir, "bad.yaml")
	os.WriteFile(f, []byte("- match:\n    rules:\n      - shell_injection\n  actions:\n    - actionner: kill\n"), 0644)
	_, err := Load(f)
	assert.Error(t, err)
}

func TestRuleValidation_NoCriteria(t *testing.T) {
	tmpDir := t.TempDir()
	f := filepath.Join(tmpDir, "bad.yaml")
	os.WriteFile(f, []byte("- name: no-criteria\n  match: {}\n  actions:\n    - actionner: kill\n"), 0644)
	_, err := Load(f)
	assert.Error(t, err)
}

func TestRuleValidation_NoActions(t *testing.T) {
	tmpDir := t.TempDir()
	f := filepath.Join(tmpDir, "bad.yaml")
	os.WriteFile(f, []byte("- name: no-actions\n  match:\n    rules:\n      - shell_injection\n  actions: []\n"), 0644)
	_, err := Load(f)
	assert.Error(t, err)
}

const testRuleYAML = `
- name: test-kill-shell-injection
  dry_run: true
  match:
    rules:
      - shell_injection
  actions:
    - actionner: kill
      parameters:
        signal: SIGKILL
`
