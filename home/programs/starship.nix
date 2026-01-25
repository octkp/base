{ config, ... }:

{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      # 青基調の落ち着いたカラー
      palette = "calm-blue";

      palettes.calm-blue = {
        navy = "#1e3a5f";
        blue = "#3b6ea5";
        steel = "#5a8fbd";
        sky = "#7eb8da";
        ice = "#a8d5e5";
        slate = "#64748b";
        white = "#e2e8f0";
        background = "#0f172a";
        error = "#ef4444";
        success = "#22c55e";
      };

      format = ''
        [](navy)$directory[](fg:navy bg:blue)$git_branch$git_status[](fg:blue bg:steel)$c$rust$golang$nodejs$php$java$kotlin$haskell$python[](fg:steel bg:sky)$docker_context[](fg:sky bg:ice)$time[](fg:ice) $cmd_duration
        $character
      '';

      directory = {
        style = "bg:navy fg:white";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = ".../";
        substitutions = {
          Documents = "󰈙 ";
          Downloads = " ";
          Music = "󰝚 ";
          Pictures = " ";
          Developer = "󰲋 ";
        };
      };

      git_branch = {
        symbol = "";
        style = "bg:blue fg:white";
        format = "[ $symbol $branch ]($style)";
      };

      git_status = {
        style = "bg:blue fg:white";
        format = "[$all_status$ahead_behind ]($style)";
      };

      nodejs = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      php = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      golang = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      python = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      rust = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      c = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      java = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      kotlin = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      haskell = {
        symbol = "";
        style = "bg:steel fg:white";
        format = "[ $symbol( $version) ]($style)";
      };

      docker_context = {
        symbol = "";
        style = "bg:sky fg:background";
        format = "[ $symbol( $context) ]($style)";
      };

      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:ice fg:background";
        format = "[  $time ]($style)";
      };

      cmd_duration = {
        min_time = 2000;
        style = "fg:slate";
        format = "took [$duration]($style)";
      };

      character = {
        success_symbol = "[❯](success)";
        error_symbol = "[❯](error)";
      };
    };
  };
}
