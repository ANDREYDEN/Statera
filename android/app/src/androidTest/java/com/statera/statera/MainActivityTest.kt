package com.statera.statera

import androidx.test.rule.ActivityTestRule
import dev.flutter.plugins.integration_test.FlutterTestRunner
import org.junit.Rule
import org.junit.runner.RunWith

@RunWith(FlutterTestRunner::class)
public class MainActivityTest {
  @Rule
  public var rule = ActivityTestRule(MainActivity::class.java, true, false)
}