if vim.g.cmp_phab_source_id ~= nil then
    require('cmp').unregister_source(vim.g.cmp_phab_source_id)
end
vim.g.cmp_phab_source_id = require('cmp').register_source('phab', require('phab.cmp').new())
