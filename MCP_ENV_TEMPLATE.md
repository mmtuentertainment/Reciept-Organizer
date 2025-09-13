# MCP Server Environment Configuration

To configure the Supabase MCP server, create a file named `.env.mcp` with the following structure:

```bash
# Supabase MCP Server Configuration
# Get your token from: https://supabase.com/dashboard/account/tokens
SUPABASE_<TOKEN_TYPE>=<your-token-here>

# Get your project ref after creating project in Epic 5.2
SUPABASE_PROJECT_<IDENTIFIER>=<your-project-ref-here>
```

Replace:
- `<TOKEN_TYPE>` with `ACCESS_TOKEN`
- `<IDENTIFIER>` with `REF`
- Fill in your actual values

**Security Note:** Never commit `.env.mcp` to version control. It's already in `.gitignore`.