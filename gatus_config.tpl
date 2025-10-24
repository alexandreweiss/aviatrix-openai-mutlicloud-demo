ui:
  header: "${customer_name} - ${application_1} connectivity dashboard"
  title: "${customer_name} - ${application_1} connectivity dashboard"
endpoints:
  - name : ${customer_website}
    method: GET
    url: "https://${customer_website}"
    interval: 5s
    group: Applications
    conditions:
      - "[STATUS] == 200"
  - name : Github
    method: GET
    url: "https://github.com"
    interval: 5s
    group: Applications
    conditions:
      - "[STATUS] == 200"
  - name : youtube.com
    method: GET
    url: "https://youtube.com"
    interval: 5s
    group: Applications
    conditions:
      - "[STATUS] == 200"