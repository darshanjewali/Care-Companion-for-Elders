package com.carecompanion.service;

import com.carecompanion.model.ChatMessage;
import com.carecompanion.repository.ChatMessageRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class ChatService {
    private final ChatMessageRepository repository;

    public ChatService(ChatMessageRepository repository) {
        this.repository = repository;
    }

    public ChatMessage send(ChatMessage message) {
        return repository.save(message);
    }

    public List<ChatMessage> conversation(Long userA, Long userB) {
        return repository.findBySenderIdAndReceiverIdOrSenderIdAndReceiverIdOrderBySentAtAsc(
                userA, userB, userB, userA
        );
    }
}
