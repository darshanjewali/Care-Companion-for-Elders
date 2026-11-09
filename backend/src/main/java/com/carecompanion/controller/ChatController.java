package com.carecompanion.controller;

import com.carecompanion.model.ChatMessage;
import com.carecompanion.service.CurrentUserService;
import com.carecompanion.service.ChatService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/chat")
@CrossOrigin
public class ChatController {
    private final ChatService chatService;
    private final CurrentUserService currentUserService;

    public ChatController(ChatService chatService, CurrentUserService currentUserService) {
        this.chatService = chatService;
        this.currentUserService = currentUserService;
    }

    @PostMapping
    public ChatMessage send(@RequestBody ChatMessage chatMessage) {
        return chatService.send(chatMessage);
    }

    @GetMapping
    public List<ChatMessage> conversation(@RequestParam Long userA, @RequestParam Long userB) {
        return chatService.conversation(userA, userB);
    }

    @GetMapping("/me")
    public List<ChatMessage> myConversation(@RequestParam Long peerId) {
        return chatService.conversation(currentUserService.getCurrentUserId(), peerId);
    }
}
