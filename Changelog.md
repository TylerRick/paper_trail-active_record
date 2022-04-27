## 1.0.0 (2022-04-27)

Breaking changes:
- `PaperTrail::ActiveRecord` was renamed to `PaperTrail::ActiveRecordExt` to fix this error with paper_trail 12.3.0 / rails 7:
    
         NameError:
           uninitialized constant PaperTrail::ActiveRecord::Type
    
                   elsif PaperTrail::RAILS_GTE_7_0 && val.is_a?(ActiveRecord::Type::Time::Value)

## 0.1.2 (2020-04-27)

- Fix: Remove debug output

## 0.1.1 (2020-04-23)

- Fix: `has_many_versions` was passing wrong value for extends

## 0.1.0 (2020-04-23)

Initial release
