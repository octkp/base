// Type definitions for zeno.zsh

declare module "@yuki-yano/zeno" {
  export interface Snippet {
    name: string;
    keyword: string;
    snippet: string;
    context?: {
      lbuffer?: string;
      rbuffer?: string;
    };
    evaluate?: boolean;
  }

  export interface Abbr {
    name: string;
    abbr: string;
    action: string;
    context?: {
      lbuffer?: string;
      rbuffer?: string;
    };
    evaluate?: boolean;
    global?: boolean;
  }

  export interface CompletionOptions {
    "--preview"?: string;
    "--preview-window"?: string;
    [key: string]: string | undefined;
  }

  export interface Completion {
    name: string;
    patterns: readonly string[] | string[];
    sourceCommand?: string;
    sourceFunction?: () => Promise<string[]> | string[];
    options?: CompletionOptions;
    callback?: (item: string) => string;
  }

  export interface Settings {
    snippets?: readonly Snippet[] | Snippet[];
    abbrs?: readonly Abbr[] | Abbr[];
    completions?: readonly Completion[] | Completion[];
  }

  export interface ConfigContext {
    projectRoot: string | undefined;
    currentDirectory: string;
  }

  export function defineConfig(
    configFn: (context: ConfigContext) => Settings | Promise<Settings>,
  ): (context: ConfigContext) => Settings | Promise<Settings>;
}
