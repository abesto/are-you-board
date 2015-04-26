package net.abesto.board.model.rule;

public class RuleCheckResult {
    protected boolean isValid;
    protected String message;

    protected RuleCheckResult() {
    }

    public static RuleCheckResult valid() {
        RuleCheckResult result = new RuleCheckResult();
        result.isValid = true;
        return result;
    }

    public static RuleCheckResult invalid(String message) {
        RuleCheckResult result = new RuleCheckResult();
        result.isValid = false;
        result.message = message;
        return result;

    }

    public boolean isValid() {
        return isValid;
    }

    public String getMessage() {
        return message;
    }
}
