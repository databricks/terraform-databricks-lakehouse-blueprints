def pytest_configure(config):
    config._metadata = None

def pytest_html_report_title(report):
    report.title = "Test Result"
