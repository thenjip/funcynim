---
---

## Releases

{%
  assign static_html_index_paths = site.static_files
    | where: "name", "index.html"
    | map: "path"
    | sort
-%}
{%- for path in static_html_index_paths -%}
  {%-
    assign first_dir = path
      | split: "/"
      | slice: 0, 2
      | join: "/"
      | append: "/"
  -%}
  {%- if first_dir == page.dir -%}
    {%- assign release = path | split: "/" | slice: 2, 1 | first %}
- [{{release}}](./{{release}})
  {%- endif -%}
{%- endfor -%}
