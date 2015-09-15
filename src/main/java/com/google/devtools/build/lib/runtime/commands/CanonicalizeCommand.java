// Copyright 2014 Google Inc. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
package com.google.devtools.build.lib.runtime.commands;

import com.google.common.base.Joiner;
import com.google.devtools.build.lib.events.Event;
import com.google.devtools.build.lib.runtime.BlazeCommand;
import com.google.devtools.build.lib.runtime.BlazeCommandUtils;
import com.google.devtools.build.lib.runtime.BlazeRuntime;
import com.google.devtools.build.lib.runtime.Command;
import com.google.devtools.build.lib.runtime.CommandEnvironment;
import com.google.devtools.build.lib.util.ExitCode;
import com.google.devtools.common.options.Option;
import com.google.devtools.common.options.OptionsBase;
import com.google.devtools.common.options.OptionsParser;
import com.google.devtools.common.options.OptionsParsingException;
import com.google.devtools.common.options.OptionsProvider;

import java.util.Collection;
import java.util.List;

/**
 * The 'blaze canonicalize-flags' command.
 */
@Command(name = "canonicalize-flags",
         options = { CanonicalizeCommand.Options.class },
         allowResidue = true,
         mustRunInWorkspace = false,
         shortDescription = "Canonicalizes a list of %{product} options.",
         help = "This command canonicalizes a list of %{product} options. Don't forget to prepend "
             + " '--' to end option parsing before the flags to canonicalize.\n"
             + "%{options}")
public final class CanonicalizeCommand implements BlazeCommand {

  public static class Options extends OptionsBase {
    @Option(name = "for_command",
            defaultValue = "build",
            category = "misc",
            help = "The command for which the options should be canonicalized.")
    public String forCommand;
  }

  @Override
  public ExitCode exec(CommandEnvironment env, OptionsProvider options) {
    BlazeRuntime runtime = env.getRuntime();
    String commandName = options.getOptions(Options.class).forCommand;
    BlazeCommand command = runtime.getCommandMap().get(commandName);
    if (command == null) {
      env.getReporter().handle(Event.error("Not a valid command: '" + commandName
          + "' (should be one of " + Joiner.on(", ").join(runtime.getCommandMap().keySet()) + ")"));
      return ExitCode.COMMAND_LINE_ERROR;
    }
    Collection<Class<? extends OptionsBase>> optionsClasses =
        BlazeCommandUtils.getOptions(
            command.getClass(), runtime.getBlazeModules(), runtime.getRuleClassProvider());
    try {
      List<String> result = OptionsParser.canonicalize(optionsClasses, options.getResidue());
      for (String piece : result) {
        env.getReporter().getOutErr().printOutLn(piece);
      }
    } catch (OptionsParsingException e) {
      env.getReporter().handle(Event.error(e.getMessage()));
      return ExitCode.COMMAND_LINE_ERROR;
    }
    return ExitCode.SUCCESS;
  }

  @Override
  public void editOptions(CommandEnvironment env, OptionsParser optionsParser) {}
}
