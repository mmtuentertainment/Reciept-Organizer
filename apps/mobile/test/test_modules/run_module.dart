#!/usr/bin/env dart

import 'dart:io';
import 'package:args/args.dart';
import 'module_definitions.dart';

/// Module Test Runner
/// 
/// Runs tests for a specific module to avoid timeouts and make debugging easier
/// 
/// Usage:
///   dart test/test_modules/run_module.dart --module core
///   dart test/test_modules/run_module.dart --module mocks --verbose
///   dart test/test_modules/run_module.dart --list

void main(List<String> arguments) async {
  final parser = ArgParser()
    ..addOption('module', abbr: 'm', help: 'Module name to test')
    ..addFlag('list', abbr: 'l', help: 'List all available modules')
    ..addFlag('verbose', abbr: 'v', help: 'Verbose output')
    ..addFlag('coverage', abbr: 'c', help: 'Generate coverage report')
    ..addFlag('help', abbr: 'h', help: 'Show help');

  final argResults = parser.parse(arguments);

  if (argResults['help'] as bool) {
    print('Module Test Runner');
    print('Usage: dart test/test_modules/run_module.dart [options]');
    print(parser.usage);
    exit(0);
  }

  if (argResults['list'] as bool) {
    listModules();
    exit(0);
  }

  final moduleName = argResults['module'] as String?;
  if (moduleName == null) {
    print('Error: Module name required');
    print('Use --list to see available modules');
    exit(1);
  }

  final module = TestModules.findModule(moduleName);
  if (module == null) {
    print('Error: Module "$moduleName" not found');
    print('Use --list to see available modules');
    exit(1);
  }

  final verbose = argResults['verbose'] as bool;
  final coverage = argResults['coverage'] as bool;

  await runModuleTests(module, verbose: verbose, coverage: coverage);
}

void listModules() {
  print('\nAvailable Test Modules:');
  print('=' * 60);
  
  for (final module in TestModules.allModules) {
    print('\n${module.name.padRight(15)} - ${module.description}');
    print('  Tests: ~${module.estimatedTests}');
    print('  Timeout: ${module.timeout.inSeconds}s');
    print('  Paths:');
    for (final path in module.testPaths) {
      print('    - $path');
    }
  }
  
  print('\n' + '=' * 60);
  print('Total estimated tests: ${TestModules.totalTests}');
  print('\nStable modules (likely to pass):');
  for (final module in TestModules.stableModules) {
    print('  - ${module.name}');
  }
  
  print('\nUnstable modules (need fixes):');
  for (final module in TestModules.unstableModules) {
    print('  - ${module.name}');
  }
}

Future<void> runModuleTests(
  TestModule module, {
  bool verbose = false,
  bool coverage = false,
}) async {
  print('\n' + '=' * 60);
  print('Running ${module.name} module tests');
  print('Description: ${module.description}');
  print('Expected tests: ~${module.estimatedTests}');
  print('Timeout: ${module.timeout.inSeconds}s');
  print('=' * 60 + '\n');

  final flutterPath = '/home/matt/FINAPP/Receipt Organizer/flutter/bin/flutter';
  
  // Build the command
  final args = <String>[
    'test',
    '--no-pub',
  ];
  
  // Add test paths
  for (final path in module.testPaths) {
    // Check if path exists
    final dir = Directory(path);
    if (await dir.exists()) {
      args.add(path);
    } else {
      print('Warning: Path not found: $path');
    }
  }
  
  // Add reporter
  args.add('--reporter');
  args.add(verbose ? 'expanded' : 'compact');
  
  // Add coverage if requested
  if (coverage) {
    args.add('--coverage');
  }

  // Add timeout
  args.add('--timeout');
  args.add('${module.timeout.inSeconds}s');

  print('Running: $flutterPath ${args.join(' ')}\n');

  final stopwatch = Stopwatch()..start();
  
  try {
    final result = await Process.run(
      flutterPath,
      args,
      workingDirectory: '/home/matt/FINAPP/Receipt Organizer/apps/mobile',
      runInShell: true,
    ).timeout(
      module.timeout + Duration(seconds: 10), // Add buffer
      onTimeout: () {
        print('\n❌ Module tests timed out after ${module.timeout.inSeconds}s');
        exit(1);
      },
    );

    stopwatch.stop();
    
    // Print output
    if (result.stdout.toString().isNotEmpty) {
      print(result.stdout);
    }
    if (result.stderr.toString().isNotEmpty) {
      print('Errors:\n${result.stderr}');
    }

    // Parse results
    final output = result.stdout.toString();
    final passed = RegExp(r'\+(\d+)').allMatches(output).lastOrNull?.group(1) ?? '0';
    final failed = RegExp(r'-(\d+)').allMatches(output).lastOrNull?.group(1) ?? '0';
    
    print('\n' + '=' * 60);
    print('Module: ${module.name}');
    print('Time: ${stopwatch.elapsed.inSeconds}s');
    print('Passed: $passed');
    print('Failed: $failed');
    
    if (result.exitCode == 0) {
      print('Status: ✅ SUCCESS');
    } else {
      print('Status: ❌ FAILED');
    }
    print('=' * 60);
    
    exit(result.exitCode);
  } catch (e) {
    print('\n❌ Error running tests: $e');
    exit(1);
  }
}