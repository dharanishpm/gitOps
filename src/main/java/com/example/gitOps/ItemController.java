package com.example.gitOps;

import org.springframework.web.bind.annotation.*;

import java.util.*;

@RestController
@RequestMapping("/api/items")
public class ItemController {
    
    private static final Map<Long, Item> items = new HashMap<>();
    private static Long nextId = 1L;

    @GetMapping
    public List<Item> getAllItems() {
        return new ArrayList<>(items.values());
    }

    @GetMapping("/{id}")
    public Item getItemById(@PathVariable Long id) {
        return items.get(id);
    }

    @PostMapping
    public Item createItem(@RequestBody Item item) {
        item.setId(nextId++);
        items.put(item.getId(), item);
        return item;
    }

    @PutMapping("/{id}")
    public Item updateItem(@PathVariable Long id, @RequestBody Item item) {
        item.setId(id);
        items.put(id, item);
        return item;
    }

    @DeleteMapping("/{id}")
    public void deleteItem(@PathVariable Long id) {
        items.remove(id);
    }

    @GetMapping("/health")
    public Map<String, String> health() {
        Map<String, String> response = new HashMap<>();
        response.put("status", "UP");
        response.put("message", "API is running");
        return response;
    }
}
