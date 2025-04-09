package com.vinsguru.tests;

import io.github.bonigarcia.wdm.WebDriverManager;

import org.openqa.selenium.Capabilities;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.chrome.ChromeDriver;
import org.openqa.selenium.chrome.ChromeOptions;
import org.openqa.selenium.firefox.FirefoxDriver;
import org.openqa.selenium.firefox.FirefoxOptions;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.testng.ITestContext;
import org.testng.annotations.AfterTest;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.BeforeTest;
import org.testng.annotations.Listeners;

import com.vinsguru.listener.TestListener;
import com.vinsguru.util.Config;
import com.vinsguru.util.Constants;

import java.net.URI;

//@Listeners({ TestListener.class })
public abstract class AbstractTest {

	private static final Logger log = LoggerFactory.getLogger(AbstractTest.class);
	protected WebDriver driver;

	@BeforeSuite
	public void setupConfig() {
		Config.initialize();
	}

	@BeforeTest
	public void setDriver(ITestContext ctx) throws Exception {

		if (Boolean.parseBoolean(Config.get(Constants.GRID_ENABLED))) {
			this.driver = getRemoteDriver();
		} else {
			this.driver = getLocalDriver();
		}
		ctx.setAttribute(Constants.DRIVER, this.driver);
		driver.manage().window().maximize();

	}

	// For local execution (without Grid)
	private WebDriver getLocalDriver() {
		String browser = System.getProperty("browser", "chrome").toLowerCase();
		switch (browser) {
		case "firefox":
			WebDriverManager.firefoxdriver().setup();
			return new FirefoxDriver(new FirefoxOptions());
		case "chrome":
		default:
			WebDriverManager.chromedriver().setup();
			return new ChromeDriver(new ChromeOptions());
		}
	}

	// For remote Selenium Grid execution
	private WebDriver getRemoteDriver() throws Exception {

		Capabilities capabilities = new ChromeOptions();
		if (Constants.FIREFOX.equalsIgnoreCase(Config.get(Constants.BROWSE))) {
		}
		String urlFormat = Config.get(Constants.GRID_URL_FORMAT);
		String hubHost = System.getProperty(Constants.GRID_HUB_HOST, Config.get(Constants.GRID_HUB_HOST));
		String url = String.format(urlFormat, hubHost);
		log.info("grid url: {}", url);
		return new RemoteWebDriver(new URI(url).toURL(), capabilities);
	}

	@AfterTest
	public void quitDriver() {
		if (driver != null) {
			driver.quit();
		}
	}
}